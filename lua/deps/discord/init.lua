require 'discord.lib.str_utils'
require 'discord.utils.json'
require 'discord.uuid'

local struct = require 'discord.deps.struct'


---@class Discord
---@field client_id string
---@field logger Logger
---@field socket string # Just for debuging
---@field pipe uv_pipe_t?
---@field waiting_activity Activity?
---@field tried_connection boolean
local Discord = {
  client_id = '',
  logger = {
    log = function() end
  },
  socket = '',
  pipe = nil,
  waiting_activity = nil,
  tried_connection = false
}

---@param client_id string
---@param logger? Logger
function Discord:setup(client_id, logger)
  if logger then self.logger = logger end
  self.client_id = client_id

  self:test_sockets(self.authorize)
  self.tried_connection = true
end

---@private
---@param callback? fun(self: Discord)
function Discord:test_sockets(callback)
  local sockets = self.get_sockets()
  local pipe = assert(vim.loop.new_pipe(false))

  for _, socket in ipairs(sockets) do
    if self.pipe then break end

    pipe:connect(socket, function(err)
      if err then
        pipe:close()
      else
        self.pipe = pipe
        self.socket = socket
        if callback then callback(self) end
      end
    end)
  end
end

---@private
---@return string[] sockets
function Discord.get_sockets()
  local f = assert(io.popen("ss -lx | grep -o '[^[:space:]]*discord[^[:space:]]*'", 'r'))
  local d = assert(f:read('*a'))
  f:close()

  return d:split '\n'
end

---@return boolean
function Discord:is_active()
  if self.pipe then
    return self.pipe:is_active() or false
  end

  return false
end

function Discord:disconnect()
  if self.pipe then
    self.pipe:close()
  end
end

---@param activity Activity?
---@param callback? fun(response: string?, err_name: string?, err_msg: string?)
function Discord:set_activity(activity, callback)
  local payload = {
    cmd = 'SET_ACTIVITY',
    nonce = Generate_uuid(),
    args = {
      activity = activity,
      pid = vim.loop:os_getpid()
    }
  }

  if not self.pipe or not self.pipe:is_active() then
    self.waiting_activity = activity
  else
    self:call(1, payload, callback)
  end
end

---@private
---@param callback? fun(response: string?, err_name: string?, err_msg: string?)
function Discord:authorize(callback)
  local payload = {
    client_id = self.client_id,
    v = 1
  }

  self:call(0, payload, function(...)
    if self.waiting_activity then self:set_activity(self.waiting_activity) end
    if callback then callback(...) end
  end)
end

---@private
---@param opcode number
---@param payload table
---@param callback? fun(response: string?, err_name: string?, err_msg: string?)
function Discord:call(opcode, payload, callback)
  callback = callback or function() end

  local function read_fn(read_err, chunk)
    if read_err then
      callback(nil, 'read', read_err)
    elseif chunk then
      callback(chunk)
    end
  end

  EncodeJSON(payload, function(body)
    local msg = struct.pack('<ii', opcode, #body) .. body

    self.pipe:write(msg, function(write_err)
      if write_err then
        callback(nil, 'write', write_err)
      else
        self.pipe:read_start(read_fn)
      end
    end)
  end)
end

return Discord
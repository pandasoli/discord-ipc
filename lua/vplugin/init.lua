ScriptPath = debug.getinfo(1, 'S').source:sub(2)

package.path = package.path .. ';lua/deps/?.lua'

local Logger = require 'lib.log'
local Discord = require 'deps.discord'


---@class VPlugin
---@field logger Logger
local VPlugin = {}

function VPlugin:setup()
  self.logger = Logger

  Discord:setup('1059272441194623126', Logger, function(response, opcode, err)
    print('VPlugin:setup', response, opcode, err)
  end)

  Discord:set_activity({
    state = 'state',
    details = 'details',

    -- cannot be empty
    -- no problem if it has only the "end" key
    timestamps = {
      start = 1,
      ['end'] = 1
    },

    assets = {
      large_image = 'large_image',
      large_text = 'large_text',
      small_image = 'small_image',
      small_text = 'small_text'
    },

    -- Cannot be empty
    buttons = {
      { label = 'Google', url = 'https://google.com' }
    }
  }, function(response, opcode, err)
    print('VPlugin:set_activity', response, opcode, err)
  end)

  vim.api.nvim_create_user_command('PrintDiscordPipe', 'lua package.loaded.vplugin.print_pipe()', { nargs = 0 })
  vim.api.nvim_create_user_command('PrintDiscordLogs', 'lua package.loaded.vplugin.logger:print()', { nargs = 0 })

  vim.api.nvim_create_autocmd('ExitPre', {
    callback = function()
      -- Unnecessary; Pipe connections end with Vim's exit.
      Discord:disconnect()
    end
  })
end

function VPlugin.print_pipe()
  print(Discord.pipe, Discord.socket)
end

return VPlugin

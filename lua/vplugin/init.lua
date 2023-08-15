ScriptPath = debug.getinfo(1, 'S').source:sub(2)

package.path = package.path .. ';lua/deps/?.lua'

local Logger = require 'lib.log'
local Discord = require 'deps.discord'


---@class VPlugin
---@field logger Logger
local VPlugin = {}

function VPlugin:setup()
  Discord:setup('1059272441194623126', Logger)

  Discord:set_activity({
    state = 'state',
    details = 'details',

    timestamps = {
      start = 1,
      ['end'] = 2,
    },

    assets = {
      large_image = 'large_image',
      large_text = 'large_text',
      small_image = 'small_image',
      small_text = 'small_text'
    },

    buttons = {
      { label = 'Google', url = 'https://google.com' }
    }
  })

  vim.api.nvim_create_user_command('PrintDiscordLogs', 'lua package.loaded.vplugin.logger:print()', { nargs = 0 })

  vim.api.nvim_create_autocmd('ExitPre', {
    callback = function()
      -- Unnecessary; Pipe connections end with Vim's exit.
      Discord:disconnect()
    end
  })
end

return VPlugin

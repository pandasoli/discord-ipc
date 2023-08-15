# Discord IPC <img width=27 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f47e.svg'/>

This library created a IPC connection with Discord to change the activity of your **Lua** <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f315.svg'/> project.  
By the way, you should read the code!

<br/>

# Usage
Clone the repository and copy `lua/deps/discord` to your project's folder.

- `git clone https://github.com/pandasoli/discord-ipc.git`
- `cp lua/deps/discord <your-project>`

<br/>

> <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4a1.svg'/>
> If you want it to show logs, well, you'll have to read the code to discover how it makes logs.

<br/>

### Functions

```lua
---@param client_id string
---@param logger? Logger
function Discord:setup(client_id, logger) end

---@param activity Activity?
---@param callback? fun(response: string?, err_name: string?, err_msg: string?)
function Discord:set_activity(activity, callback) end

function Discord:disconnect() end
```

<br/>

# Development

I relied a lot on the script that the plugin [presence.nvim](https://github.com/andweeb/presence.nvim) uses.

---@class ActivityAssets
---@field large_image? string
---@field large_text?  string
---@field small_image? string
---@field small_text?  string

---@class ActivityButton
---@field label string
---@field url   string

---@class Activity
---@field state?   string
---@field details? string
---@field assets   ActivityAssets
---@field buttons? ActivityButton[]

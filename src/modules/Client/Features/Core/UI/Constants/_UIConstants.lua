--[=[
    @class UIConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UIConstants = {
    Screens = {
        "Primary",
        "Tooltips"
    },
    UINameToGroup = {
        InventoryUI = "Exclusive",
        
        ItemTooltipUI = "Persistent"
    }
}

-- [ Types ] --
export type Module = typeof(UIConstants)

return UIConstants :: Module
--[=[
    @class TopicConstants
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TopicConstants = {
    Inventory = {
        ItemEquipped = "Inventory/ItemEquipped",
        ItemUnequipped = "Inventory/ItemUnequipped",
        ItemUpdated = "Inventory/ItemUpdated",
        ItemAdded = "Inventory/ItemAdded",
        ItemRemoved = "Inventory/ItemRemoved",
    }
}

-- [ Types ] --
export type Module = typeof(TopicConstants)

-- [ Private Functions ] --

-- [ Public Functions ] --

return TopicConstants :: Module
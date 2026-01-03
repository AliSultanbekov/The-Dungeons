--[=[
    @class InventoryConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryConstants = {
    Pages = {
        ["Items"] = {"Materials"},
        ["Equipment"] = {"Weapons"},
    },

    ItemTypeToPage = {
        ["Materials"] = "Items",
        ["Weapons"] = "Equipment"
    }
} :: { 
    Pages: {
        [string]: { string }
    },

    ItemTypeToPage: {
        [string]: string
    }
}

-- [ Types ] --
export type Module = typeof(InventoryConstants)

return InventoryConstants :: Module
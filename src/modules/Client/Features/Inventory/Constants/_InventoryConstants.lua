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

    Sections = {
        ["Materials"] = {"Materials"},
        ["Weapons"] = {"Weapons"}
    },

    SectionToPage = {
        ["Materials"] = "Items",
        ["Weapons"] = "Equipment"
    },

    ItemTypeToSections = {
        ["Materials"] = "Materials",
        ["Weapons"] = "Weapons"
    }
} :: { 
    Pages: {
        [string]: { string }
    },

    Sections: {
        [string]: { string }
    },

    SectionToPage: {
        [string]: string
    },

    ItemTypeToSections: {
        [string]: string
    }
}

-- [ Types ] --
export type Module = typeof(InventoryConstants)

return InventoryConstants :: Module
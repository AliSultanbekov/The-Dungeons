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
        ["Items"] = {"Materials"}    
    },

    Sections = {
        ["Materials"] = {"Materials"}
    },

    SectionToPage = {
        ["Materials"] = "Items"
    },

    ItemTypeToSections = {
        ["Materials"] = "Materials"
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
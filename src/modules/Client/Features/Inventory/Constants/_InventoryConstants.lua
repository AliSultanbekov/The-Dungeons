--[=[
    @class InventoryConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryConstants = {
    Tabs = {
        ["Equipment"] = {"Weapons"}    
    },

    Sections = {
        ["Weapons"] = {"Weapons"}
    },

    SectionToTab = {
        ["Weapons"] = "Equipment"
    },

    ItemTypeToSections = {
        ["Weapons"] = "Weapons"
    }
} :: { 
    Tabs: {
        [string]: { string }
    },

    Sections: {
        [string]: { string }
    },

    SectionToTab: {
        [string]: string
    },

    ItemTypeToSections: {
        [string]: string
    }
}

-- [ Types ] --
export type Module = typeof(InventoryConstants)

return InventoryConstants :: Module
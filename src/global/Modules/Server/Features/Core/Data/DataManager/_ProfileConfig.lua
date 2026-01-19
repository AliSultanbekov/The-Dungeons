--[=[
    @class ProfileConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.Parent.loader).load(script)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ProfileConfig = {
    Template = {
        Inventory = {
            Weapons = {},
            Materials = {}
        },
        
        Currencies = {
            Coins = 0
        },

        Equipped = {
            Toolbar = {},
            Equipment = {},
        }
    },
    Leaderstats = {"Coins"}
} :: { Template: ProfileTemplate, Leaderstats: { string }}

-- [ Types ] --

export type ProfileTemplate = {
    Inventory: {
        Weapons: {},
        Materials: {},
    },

    Currencies: {
        Coins: number
    },

    Equipped: {
        Toolbar: {
        },
        Equipment: {
        }
        
    }
}

return ProfileConfig
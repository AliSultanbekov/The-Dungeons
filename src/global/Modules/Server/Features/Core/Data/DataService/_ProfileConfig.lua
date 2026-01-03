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
            Weapons = {}
        },
        
        Currencys = {
            Coins = 0
        }
    },
    Leaderstats = {"Coins"}
} :: { Template: ProfileTemplate, Leaderstats: { string }}

-- [ Types ] --

export type ProfileTemplate = {
    Inventory: {
        Weapons: {}
    },

    Currencys: {
        Coins: number
    }
}

return ProfileConfig
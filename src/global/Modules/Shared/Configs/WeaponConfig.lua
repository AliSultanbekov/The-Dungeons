--[=[
    @class WeaponConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WeaponConfig = {
    ["Wooden Sword"] = {
        Image = "rbxassetid://...",
        Rarity = "Celestial",
        BasicAttack = {
            Name = "WoodenSwordBasicAttack",
            Combo = {
                [1] = { Animation = "rbxassetid://...", Damage = 2 },
                [2] = { Animation = "rbxassetid://...", Damage = 2 },
                [3] = { Animation = "rbxassetid://...", Damage = 3 },
            }
        },
        SpecialAttack = {
            Name = "WoodenSwordSpecialAttack",
            Animation = "rbxassetid://...",
            Damage = 2,
        }
    }
} :: {
    [string]: {
        Image: string,
        Rarity: string,
        BasicAttack: {
            Name: string,
            Combo: { 
                [number]: {
                    Animation: string,
                    Damage: number
                }
            }
        },
        SpecialAttack: {
            Name: string,
            Animation: string,
            Damage: number
        },
    }
}

-- [ Types ] --
export type Module = typeof(WeaponConfig)

return WeaponConfig :: Module
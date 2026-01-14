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
            AbilityName = "WoodenSwordBasicAttack",
            MaxDelay = 0.8,
            Combo = {
                [1] = {
                    Animation = "rbxassetid://94075119278445",
                    Damage = 5,
                    Range = 4,
                    MinDot = 0.6,
                },
                [2] = {
                    Animation = "rbxassetid://94075119278445",
                    Damage = 5,
                    Range = 4,
                    MinDot = 0.6,
                },
                [3] = {
                    Animation = "rbxassetid://94075119278445",
                    Damage = 5,
                    Range = 4,
                    MinDot = 0.6,
                },
            }
        },
        SpecialAttack = {
            Range = 4,
            MinDot = 0.6,
            Animation = "rbxassetid://94075119278445",
            Name = "WoodenSwordSpecialAttack",
            Damage = 2,
        }
    }
} :: {
    [string]: {
        Image: string,
        Rarity: string,
        BasicAttack: {
            AbilityName: string,
            MaxDelay: number,
            Combo: { 
                [number]: {
                    Animation: string,
                    Damage: number,
                    Range: number,
                    MinDot: number,
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
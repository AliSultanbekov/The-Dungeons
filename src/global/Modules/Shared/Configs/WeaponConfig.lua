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
            Range = 5,
            MinDot = 0.7,
            Animation = "rbxassetid://94075119278445",
            Name = "WoodenSwordBasicAttack",
            Damage = 5,
        },
        SpecialAttack = {
            Range = 5,
            MinDot = 0.7,
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
            Animation: string,
            Name: string,
            --[[Combo: { 
                [number]: {
                    Animation: string,
                    Damage: number
                }
            }]]
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
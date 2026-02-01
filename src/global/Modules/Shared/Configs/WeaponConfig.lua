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
            ComboTimeout = 0.4,
            Combo = {
                [1] = {
                    Animation = "rbxassetid://99630984913419",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Time = 1,
                },
                [2] = {
                    Animation = "rbxassetid://73399443862076",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Time = 1,
                },
                [3] = {
                    Animation = "rbxassetid://129784332509594",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Time = 1,
                },
                [4] = {
                    Animation = "rbxassetid://116170208433386",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Time = 1,
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
            ComboTimeout: number,
            Combo: { 
                [number]: {
                    Animation: string,
                    Damage: number,
                    Range: Vector3,
                    Angle: number,
                    Time: number
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
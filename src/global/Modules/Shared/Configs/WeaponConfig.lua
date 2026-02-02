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
            ComboTimeout = 1,
            Combo = {
                [1] = {
                    Animation = "rbxassetid://99630984913419",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Duration = 0.7,
                    CommitTime = 0.2
                },
                [2] = {
                    Animation = "rbxassetid://73399443862076",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Duration = 0.7,
                    CommitTime = 0.2
                },
                [3] = {
                    Animation = "rbxassetid://129784332509594",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Duration = 0.7,
                    CommitTime = 0.2
                },
                [4] = {
                    Animation = "rbxassetid://116170208433386",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Duration = 0.7,
                    CommitTime = 0.2
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
                    Duration: number,
                    CommitTime: number,
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
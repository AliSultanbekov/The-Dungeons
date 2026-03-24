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
                    AnimationID = "rbxassetid://71998974013014",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,4.5),
                    Angle = 0.6,
                    Duration = 1,
                    CommitTime = 0.3
                },
                [2] = {
                    AnimationID = "rbxassetid://113864789898995",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,4.5),
                    Angle = 0.6,
                    Duration = 1,
                    CommitTime = 0.25
                },
                [3] = {
                    AnimationID = "rbxassetid://128432014656527",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,4.5),
                    Angle = 0.6,
                    Duration = 1,
                    CommitTime = 0.28
                },
                [4] = {
                    AnimationID = "rbxassetid://94221170157791",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,4.5),
                    Angle = 0.6,
                    Duration = 1,
                    CommitTime = 0.25
                },
            }
        },
        SpecialAttack = {
            Range = 4,
            MinDot = 0.6,
            AnimationID = "rbxassetid://94075119278445",
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
                    AnimationID: string,
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
            AnimationID: string,
            Damage: number
        },
    }
}

-- [ Types ] --
export type Module = typeof(WeaponConfig)

return WeaponConfig :: Module
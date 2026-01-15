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
            MaxDelay = 1.5,
            Combo = {
                [1] = {
                    Animation = "rbxassetid://123019341128128",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Time = 0.5,
                },
                [2] = {
                    Animation = "rbxassetid://130413544906065",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Time = 0.5,
                },
                [3] = {
                    Animation = "rbxassetid://119564035903071",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Time = 0.5,
                },
                [4] = {
                    Animation = "rbxassetid://85449331468043",
                    Damage = 20,
                    Range = Vector3.new(3.5,3.5,3.5),
                    Angle = 0.6,
                    Time = 0.5,
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
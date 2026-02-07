--[=[
    @class AbilityConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AbilityConfig = {
    ConflictRules = {
        Attack = {"Attack"},
        Defense = {"Defense"},
    },
    InterruptRules = {
        Defense = {"Attack"},
        Attack = {"Defense", "SubDefense"},
    },
    Abilities = {
        ["DefaultBasicAttack"] = {
            Category = "Attack",
            Weight = 1,

            CooldownDuration = 0.1,
        },
        ["Block"] = {
            Category = "Defense",
            Weight = 1,
            Components = {"Blocking"},

            Duration = math.huge,
            AnimationID = "rbxassetid://87451259660096",
        },
        ["Parry"] = {
            Weight = 1,
            Components = {"Parrying"},

            Duration = 0.2,
            CooldownDuration = 0.4,
        }
    }
}

-- [ Types ] --
export type Module = typeof(AbilityConfig)

return AbilityConfig :: Module
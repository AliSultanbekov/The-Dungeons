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
        Movement = {"Movement"}
    },
    InterruptRules = {
        Defense = {"Attack"},
        Attack = {"Defense"},
        Movement = {"Attack", "Defense"},
    },
    Abilities = {
        ["DefaultBasicAttack"] = {
            Category = "Attack",
            Weight = 1,

            CooldownDuration = 0.2,
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

            Duration = 0.25,
            CooldownDuration = 0.3,
        },
        ["Dash"] = {
            Weight = 1,
            Components = {"Dodging"},

            Duration = 0.2,
            CooldownDuration = 1,
        }
    }
}

-- [ Types ] --
export type Module = typeof(AbilityConfig)

return AbilityConfig :: Module
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
        Attack = {"Attack", "Defense", "SubDefense"},
        Defense = {"Defense", "Attack"},
        SubDefense = {"SubDefense", "Attack"},
        Movement = {"Attack", "Defense", "SubDefense"},
    },
    InterruptRules = {
        Defense = {},
        Attack = {},
        Movement = {},
        SubDefense = {},
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
            UsableOnParryStun = true,
            Components = {"Blocking"},

            Duration = math.huge,
            AnimationID = "rbxassetid://87451259660096",
        },
        ["Parry"] = {
            Category = "SubDefense",
            Weight = 1,
            UsableOnParryStun = true,
            Components = {"Parrying"},

            Duration = 0.2,
            CooldownDuration = 0.35,
        },
        ["Dash"] = {
            Weight = 1,
            Category = "Movement",
            UsableOnParryStun = true,
            Components = {"Dodging"},

            Duration = 0.45,
            CooldownDuration = 0.8,

            ForwardAnimationID = "rbxassetid://115264084707994",
            BackwardAnimationID = "rbxassetid://129789334771703",
            RightAnimationID = "rbxassetid://112182854091549",
            LeftAnimationID = "rbxassetid://123726272767493",
        }
    }
}

-- [ Types ] --
export type Module = typeof(AbilityConfig)

return AbilityConfig :: Module
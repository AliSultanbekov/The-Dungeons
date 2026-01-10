--[=[
    @class CombatKeyMap
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local InputKeyMap = require("InputKeyMap")
local InputKeyMapList = require("InputKeyMapList")
local InputModeTypes = require("InputModeTypes")

-- [ Constants ] --

-- [ Variables ] --
local Actions = {
    ["BASIC_ATTACK"] = "BASIC_ATTACK",
    ["SPECIAL_ATTACK"] = "SPECIAL_ATTACK"
}

-- [ Module Table ] --
local CombatKeyMap = {
    Actions = Actions,
    KeyMaps = {
        [Actions.BASIC_ATTACK] = InputKeyMapList.new(
            Actions.BASIC_ATTACK,
            {
                InputKeyMap.new(InputModeTypes.Mouse, {
                    Enum.UserInputType.MouseButton1
                })
            },
            {
                bindingName = "Basic Attack",
                rebindable = true,
            }
        ),
        [Actions.SPECIAL_ATTACK] = InputKeyMapList.new(
            Actions.SPECIAL_ATTACK,
            {
                InputKeyMap.new(InputModeTypes.Mouse, {
                    Enum.UserInputType.MouseButton2
                })
            },
            {
                bindingName = "Special Attack",
                rebindable = true,
            }
        )
    }
}

-- [ Types ] --
export type Module = typeof(CombatKeyMap)

return CombatKeyMap :: Module
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
    ["BLOCK"] = "BLOCK"
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
        [Actions.BLOCK] = InputKeyMapList.new(
            Actions.BLOCK,
            {
                InputKeyMap.new(InputModeTypes.Keyboard, {
                    Enum.KeyCode.F
                })
            },
            {
                bindingName = "Block",
                rebindable = true,
            }
        )
    }
}

-- [ Types ] --
export type Module = typeof(CombatKeyMap)

return CombatKeyMap :: Module
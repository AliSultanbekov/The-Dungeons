--[=[
    @class CombatKeyMap
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local InputKeyMap = require("InputKeyMap")
local InputKeyMapList = require("InputKeyMapList")
local InputModeTypes = require("InputModeTypes")

-- [ Constants ] --

-- [ Variables ] --
local Actions = {
    ["WEAPON_PRIMARY"] = "WEAPON_PRIMARY"
}

-- [ Module Table ] --
local CombatKeyMap = {
    Actions = Actions,
    KeyMaps = {
        [Actions.WEAPON_PRIMARY] = InputKeyMapList.new(
            Actions.WEAPON_PRIMARY,
            {
                InputKeyMap.new(InputModeTypes.Mouse, {
                    Enum.UserInputType.MouseButton1
                })
            },
            {
                bindingName = "Weapon Primary",
                rebindable = true,
            }
        )
    }
}

-- [ Types ] --
export type Module = typeof(CombatKeyMap)

return CombatKeyMap :: Module
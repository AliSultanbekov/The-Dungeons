--[=[
    @class KeyMap
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
    ["TOGGLE_INVENTORY_UI"] = "TOGGLE_INVENTORY_UI"
}

-- [ Module Table ] --
local KeyMap = {
    Actions = Actions,
    KeyMaps = {
        [Actions.TOGGLE_INVENTORY_UI] = InputKeyMapList.new(
            Actions.TOGGLE_INVENTORY_UI,
            {
                InputKeyMap.new(InputModeTypes.Keyboard, {
                    Enum.KeyCode.B
                })
            },
            {
                bindingName = "Toggle InventoryUI",
                rebindable = true,
            }
        )
    }
}

-- [ Types ] --
export type Module = typeof(KeyMap)

return KeyMap :: Module
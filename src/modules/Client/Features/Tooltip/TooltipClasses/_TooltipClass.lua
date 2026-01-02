--[=[
    @class TooltipClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local UIUtil = require("UIUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TooltipClass = {}
TooltipClass.__index = TooltipClass

-- [ Types ] --
type EventBusClient = typeof(require("EventBusClient"))
type TooltipUI = {
    UIScale: UIScale
} & GuiObject

export type ObjectData = {
    _UI: TooltipUI,
    _HookedToCursor: boolean
}
export type Object = ObjectData & Module
export type Module = typeof(TooltipClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function TooltipClass.new(ui: TooltipUI): Object
    local self = setmetatable({} :: any, TooltipClass) :: Object

    self._UI = ui
    self._HookedToCursor = false

    return self
end

function TooltipClass.Show(self: Object)
    UIUtil:ForceUIOpen(self._UI, true)
end

function TooltipClass.Hide(self: Object)
    UIUtil:ForceUIClose(self._UI)
end

function TooltipClass.GetUI(self: Object)
    return self._UI
end

function TooltipClass.SetHookToCursor(self: Object, value: boolean)
    self._HookedToCursor = value
end

function TooltipClass.IsHookedToCursor(self: Object)
    return self._HookedToCursor == true
end

function TooltipClass.UpdatePosition(self: Object, position: UDim2)
    local UI = self:GetUI()

    UI.Position = position
end

return TooltipClass :: Module
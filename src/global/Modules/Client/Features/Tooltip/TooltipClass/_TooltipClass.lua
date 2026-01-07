--[=[
    @class TooltipClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local TooltipClassTypes = require("./_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TooltipClass = {}
TooltipClass.__index = TooltipClass

-- [ Types ] --
type Info = TooltipClassTypes.Info
type Behavior = TooltipClassTypes.Behavior
type Context = {
    UI: GuiObject,
    Behavior: Behavior,
    DestroySignal: Signal.Signal<nil>
}
export type ObjectData = {
    _UI: GuiObject,
    _AttachToMouse: boolean,
    _Behavior: Behavior,

    DestroySignal: Signal.Signal<nil>
}
export type Object = ObjectData & {
    UpdateUI: (self: Object, info: Info) -> (),
    UpdateCbs: (self: Object, cbs: { [any]: any }) -> (),
    UpdatePosition: (self: Object, position: UDim2) -> (),
    Show: (self: Object) -> (),
    Hide: (self: Object) -> (),
    GetUI: (self: Object) -> GuiObject,
    SetAttachToMouse: (self: Object, value: boolean) -> (),
    IsAttachedToMouse: (self: Object) -> boolean,
}

export type Module = typeof(TooltipClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function TooltipClass.new(context: Context): Object
    local self = setmetatable({} :: any, TooltipClass) :: Object

    self._UI = context.UI
    self._AttachToMouse = false
    self._Behavior = context.Behavior
    self.DestroySignal = context.DestroySignal

    return self
end

function TooltipClass.UpdateCbs(self: Object, cbs: {})
    self._Behavior:UpdateCbs(cbs)
end
    
function TooltipClass.UpdateUI(self: Object, info: Info)
    self._Behavior:UpdateUI(info)
end

function TooltipClass.UpdatePosition(self: Object, position: UDim2)
    self._UI.Position = position
end

function TooltipClass.Show(self: Object)
    self._Behavior:Show()
end

function TooltipClass.Hide(self: Object)
    self._Behavior:Hide()
end

function TooltipClass.GetUI(self: Object): GuiObject
    return self._UI
end

function TooltipClass.SetAttachToMouse(self: Object, value: boolean)
    self._AttachToMouse = value
end

function TooltipClass.IsAttachedToMouse(self: Object): boolean
    return self._AttachToMouse == true
end

return TooltipClass :: Module
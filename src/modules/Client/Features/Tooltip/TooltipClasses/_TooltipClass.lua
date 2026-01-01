--[=[
    @class TooltipClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local UIUtil = require("UIUtil")
local UIAnimUtil = require("UIAnimUtil")
local TopicConstants = require("TopicConstants")

-- [ Constants ] --
local SHOW_TWEENINFO = TweenInfo.new(0.1)
local HIDE_TWEENINFO = TweenInfo.new(0.1)

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
    _EventBusClient: EventBusClient
}
export type Object = ObjectData & Module
export type Module = typeof(TooltipClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function TooltipClass.new(ui: TooltipUI, eventBusClient: EventBusClient): Object
    local self = setmetatable({} :: any, TooltipClass) :: Object

    self._UI = ui
    self._EventBusClient = eventBusClient

    return self
end

function TooltipClass.Show(self: Object)

end

function TooltipClass.Hide(self: Object)

end

return TooltipClass :: Module
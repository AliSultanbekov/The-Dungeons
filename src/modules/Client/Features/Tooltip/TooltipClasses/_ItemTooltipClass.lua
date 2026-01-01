--[=[
    @class ItemTooltipClass
]=]

-- [ Roblox Services ] --
local StarterGui = game:GetService("StarterGui")

-- [ Imports ] --
local TooltipClass = require("./_TooltipClass")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local TopicConstants = require("TopicConstants")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemTooltipClass = setmetatable({}, TooltipClass)
ItemTooltipClass.__index = ItemTooltipClass

-- [ Types ] --
type EventBusClient = typeof(require("EventBusClient"))
type ItemTooltipUI = typeof(StarterGui.Tooltips.ItemTooltip)
export type ObjectData = {

}
export type Object = ObjectData & Module & TooltipClass.Object
export type Module = typeof(ItemTooltipClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function ItemTooltipClass.new(ui: ItemTooltipUI, eventBusClient: EventBusClient): Object
    local self = setmetatable(TooltipClass.new(ui, eventBusClient), ItemTooltipClass) :: Object

    task.defer(function()
        while true do
            task.wait(2)

            self:Show()

            task.wait(2)

            self:Hide()
        end
    end)

    return self
end

function ItemTooltipClass.Show(self: Object)
    self._EventBusClient:Publish(TopicConstants.UI.Open("ItemTooltipUI"))
end

function ItemTooltipClass.Hide(self: Object)
    self._EventBusClient:Publish(TopicConstants.UI.Close("ItemTooltipUI"))
end

return ItemTooltipClass :: Module
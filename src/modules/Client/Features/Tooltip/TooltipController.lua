--[=[
    @class TooltipController
]=]

-- [ Roblox Services ] --
local StarterGui = game:GetService("StarterGui")

-- [ Imports ] --
local ItemTooltipClass = require("./TooltipClasses/_ItemTooltipClass")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TooltipController = {}

-- [ Types ] --
type ItemTooltipUI = typeof(StarterGui.Tooltips.ItemTooltip)

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIController: typeof(require("UIController")),
    _EventBusClient: typeof(require("EventBusClient")),

    _Tooltips: {
        ItemTooltip: ItemTooltipClass.Object,
    }
}

export type Module = typeof(TooltipController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TooltipController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIController = self._ServiceBag:GetService(require("UIController"))
    self._EventBusClient = self._ServiceBag:GetService(require("EventBusClient"))
end

function TooltipController.Start(self: Module)
    self._UIController:UIReady():Then(function()  
        local ItemTooltipUI = self._UIController:GetUI("ItemTooltipUI") :: ItemTooltipUI

        self._Tooltips = {
            ItemTooltip = ItemTooltipClass.new(ItemTooltipUI, self._EventBusClient)
        }
    end)
end

return TooltipController :: Module
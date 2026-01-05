--[=[
    @class TooltipController
]=]

-- [ Roblox Services ] --
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- [ Imports ] --
local TooltipClass = require("./TooltipClasses/_TooltipClass")
local ItemTooltipClass = require("./TooltipClasses/_TooltipClass")
local ItemActionTooltipClass = require("./TooltipClasses/_ItemActionTooltipClass")

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
    _UserInputController: typeof(require("UserInputController")),

    _Tooltips: {
        [string]: TooltipClass.Object,
    },
    _ActiveTooltip: string?
}

export type Module = typeof(TooltipController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --


function TooltipController.SetCallBacks(self: Module, tooltipType: string, cbs: {[string]: (...any) -> (...any)})
    local Tooltip = self._Tooltips[tooltipType]

    if not Tooltip then
        warn(string.format("[TooltipController] No Tooltip found for type '%s'", tooltipType))
        return
    end

    Tooltip:SetCallBacks(cbs)
end

function TooltipController.GetActive(self: Module): string?
    return self._ActiveTooltip
end

function TooltipController.UpdatePosition(self: Module, tooltipType: string, position: UDim2)
    local Tooltip = self._Tooltips[tooltipType]

    if not Tooltip then
        warn(string.format("[TooltipController] No Tooltip found for type '%s'", tooltipType))
        return
    end

    Tooltip:UpdatePosition(position)
end

function TooltipController.UpdateInfo(self: Module, tooltipType: string, info: { any })
    local Tooltip = self._Tooltips[tooltipType]

    if not Tooltip then
        warn(string.format("[TooltipController] No Tooltip found for type '%s'", tooltipType))
        return
    end

    Tooltip:UpdateInfo(info)
end

function TooltipController.Show(self: Module, tooltipType: string, hookToCursor: boolean?)
    local Tooltip = self._Tooltips[tooltipType]

    if not Tooltip then
        warn(string.format("[TooltipController] No Tooltip found for type '%s'", tooltipType))
        return
    end

    if self._ActiveTooltip and self._ActiveTooltip ~= tooltipType then
        self:Hide(self._ActiveTooltip)
    end

    Tooltip:Show()
    Tooltip:SetHookToCursor(hookToCursor or false)

    self._ActiveTooltip = tooltipType
end

function TooltipController.Hide(self: Module, tooltipType: string)
    if self._ActiveTooltip ~= tooltipType then
        return
    end

    local Tooltip = self._Tooltips[tooltipType]

    if not Tooltip then
        warn(string.format("[TooltipController] No Tooltip found for type '%s'", tooltipType))
        return
    end

    Tooltip:Hide()
    Tooltip:SetHookToCursor(false)
    Tooltip:SetCallBacks({})

    self._ActiveTooltip = nil
end

function TooltipController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIController = self._ServiceBag:GetService(require("UIController"))
    self._UserInputController = self._ServiceBag:GetService(require("UserInputController"))
    self._Tooltips = {}
    self._ActiveTooltip = nil
end

function TooltipController.Start(self: Module)
    self._UIController:UIReady():Then(function()
        local ItemTooltipUI = self._UIController:GetUI("ItemTooltipUI") :: ItemTooltipUI
        local ItemActionTooltipUI = self._UIController:GetUI("ItemActionTooltipUI") :: ItemTooltipUI

        self._Tooltips["ItemTooltip"] = ItemTooltipClass.new(ItemTooltipUI)
        self._Tooltips["ItemActionTooltip"] = ItemActionTooltipClass.new(ItemActionTooltipUI)

        UserInputService.InputChanged:Connect(function(input: InputObject, gameProcesse:boolean)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end

            if not self._ActiveTooltip then
                return
            end
    
            local TooltipObject = self._Tooltips[self._ActiveTooltip]
    
            if not TooltipObject:IsHookedToCursor() then
                return
            end
    
            local MouseLocation = UserInputService:GetMouseLocation()
            local MousePosition = UDim2.new(0, MouseLocation.X, 0, MouseLocation.Y - 40)
    
            TooltipObject:UpdatePosition(MousePosition)
        end)
    end)
end

return TooltipController :: Module
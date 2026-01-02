--[=[
    @class TooltipController
]=]

-- [ Roblox Services ] --
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

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
    _UserInputController: typeof(require("UserInputController")),

    _Tooltips: {
        ["ItemTooltip" | string]: ItemTooltipClass.Object,
    },
    _ActiveTooltip: string?
}

export type Module = typeof(TooltipController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TooltipController.UpdateInfo(self: Module, tooltipType: string, info: any)
    local Tooltip = self._Tooltips[tooltipType]

    Tooltip:UpdateInfo(info)
end

function TooltipController.Show(self: Module, tooltipType: string, hookToCursor: boolean?)
    local Tooltip = self._Tooltips[tooltipType]

    if self._ActiveTooltip then
        self:Hide(self._ActiveTooltip)
    end

    Tooltip:Show()
    Tooltip:SetHookToCursor(hookToCursor or false)

    self._ActiveTooltip = tooltipType
end

function TooltipController.Hide(self: Module, tooltipType: string)
    local Tooltip = self._Tooltips[tooltipType]

    Tooltip:Hide()
    Tooltip:SetHookToCursor(false)

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

        self._Tooltips["ItemTooltip"] = ItemTooltipClass.new(ItemTooltipUI)

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
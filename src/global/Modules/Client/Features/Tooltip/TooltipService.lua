--[=[
    @class TooltipService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- [ Imports ] --
local TooltipClassBuilder = require("./TooltipClass/_TooltipClassBuilder")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

-- [ Module Table ] --
local TooltipService = {}

-- [ Types ] --
type ItemTooltipUI = typeof(PlayerGui.Tooltips.ItemTooltip)
type TooltipObject = TooltipClassBuilder.TooltipObject
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIManager: typeof(require("UIManager")),
    _TooltipMaid: Maid.Maid,
    _TooltipObjects: { [string]: TooltipObject },
    _ActiveTooltip: string?,
}

export type Module = typeof(TooltipService) & ModuleData

-- [ Private Functions ] --
function TooltipService._GetTooltipUI(self: Module, tooltipType: string): GuiObject
    if tooltipType == "ItemTooltip" then
        return self._UIManager:GetUI("ItemTooltipUI")
    elseif tooltipType == "ItemActionTooltip" then
        return self._UIManager:GetUI("ItemActionTooltipUI")
    end

    error(`Unknown tooltip type "{tooltipType}"`)
end

-- [ Public Functions ] --
function TooltipService.IsAttachedToMouse(self: Module, tooltipType: string): boolean
    local TooltipObject = self._TooltipObjects[tooltipType]
    return TooltipObject:IsAttachedToMouse()
end

function TooltipService.UpdatePosition(self: Module, tooltipType: string, position: UDim2)
    local TooltipObject = self._TooltipObjects[tooltipType]
    TooltipObject:UpdatePosition(position)
end

function TooltipService.UpdateCbs(self: Module, tooltipType: string, cbs: { [any]: any })
    local TooltipObject = self._TooltipObjects[tooltipType]
    TooltipObject:UpdateCbs(cbs)
end

function TooltipService.UpdateUI(self: Module, tooltipType: string, info: { [any]: any })
    local TooltipObject = self._TooltipObjects[tooltipType]
    TooltipObject:UpdateUI(info)
end

function TooltipService.Show(self: Module, tooltipType: string, attachToCursor: boolean?)
    if self._ActiveTooltip == tooltipType then
        return
    end

    self._TooltipMaid:DoCleaning()
    
    local TooltipObject = self._TooltipObjects[tooltipType]
    TooltipObject:Show()
    TooltipObject:SetAttachToMouse(attachToCursor or false)

    self._ActiveTooltip = tooltipType

    self._TooltipMaid:Add(function()
        if self._ActiveTooltip then
            TooltipObject:Hide()
        end
        
        self._ActiveTooltip = nil
    end)

    self._TooltipMaid:Add(TooltipObject.DestroySignal:Connect(function()
        self._TooltipMaid:DoCleaning()
    end))
end

function TooltipService.Hide(self: Module, tooltipType: string)
    if self._ActiveTooltip ~= tooltipType then
        return
    end

    local TooltipObject = self._TooltipObjects[tooltipType]
    TooltipObject:Hide()
    TooltipObject:SetAttachToMouse(false)


    self._TooltipMaid:DoCleaning()
end

function TooltipService.GetActive(self: Module)
    return self._ActiveTooltip
end

function TooltipService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIManager = self._ServiceBag:GetService(require("UIManager"))
    self._TooltipMaid = Maid.new()
    self._TooltipObjects = {}
    self._ActiveTooltip = nil
end

function TooltipService.Start(self: Module)
    self._UIManager:UIReady():Then(function()
        self._TooltipObjects["ItemTooltip"] = TooltipClassBuilder:Build("ItemTooltip", self:_GetTooltipUI("ItemTooltip"))
        self._TooltipObjects["ItemActionTooltip"] = TooltipClassBuilder:Build("ItemActionTooltip", self:_GetTooltipUI("ItemActionTooltip"))

        UserInputService.InputChanged:Connect(function(input: InputObject, gameProcesse:boolean)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end
    
            local TooltipType = self._ActiveTooltip

            if not TooltipType then
                return
            end

            if not self:IsAttachedToMouse(TooltipType) then
                return
            end
    
            local MouseLocation = UserInputService:GetMouseLocation()
            local MousePosition = UDim2.new(0, MouseLocation.X, 0, MouseLocation.Y - 40)
    
            self:UpdatePosition(TooltipType, MousePosition)
        end)
    end)
end

return TooltipService :: Module
--[=[
    @class UIUtil
]=]

-- [ Roblox Services ] --
local TweenService = game:GetService("TweenService")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local DEFAULT_TWEEN = TweenInfo.new(0.1)

-- [ Variables ] --
local x = script.Parent.Parent.test


-- [ Module Table ] --
local UIUtil = {
    Cache = {}
}

-- [ Types ] --
export type Module = typeof(UIUtil)

-- [ Private Functions ] --
function _CleanUpTween(self: Module, ui: any)
    local Tween = self.Cache[ui]

    if not Tween then
        return
    end

    Tween:Destroy()

    self.Cache[ui] = nil
end

-- [ Public Functions ] --
function UIUtil.AnimateScale(self: Module, uiScale: UIScale, value: number, tweenInfo: TweenInfo?, onCompleted: () -> ()?)
    _CleanUpTween(self, uiScale)

    local NewScale = value

    local Tween = TweenService:Create(uiScale, tweenInfo or DEFAULT_TWEEN, { Scale = NewScale })

    self.Cache[uiScale] = Tween

    Tween.Completed:Connect(function()
        _CleanUpTween(self, uiScale)

        if onCompleted then
            onCompleted()
        end
    end)

    Tween:Play()
end

function UIUtil.SetScale(self: Module, uiScale: UIScale, value: number)
    uiScale.Scale = value
end


function UIUtil.OpenUI(self: Module, ui: GuiObject, tweenInfo: TweenInfo?, HasUIScaleComponent: boolean?, onCompleted: () -> ()?)
    local UIScale = ui:FindFirstChildOfClass("UIScale")

    if not UIScale then
        local NewUIScale = Instance.new("UIScale")
        NewUIScale.Parent = ui
        NewUIScale.Scale = 0
        UIScale = NewUIScale
    end

    if not UIScale then
        return
    end

    if HasUIScaleComponent then
        UIScale:SetAttribute("IsAnimating", true)
    end

    local NewScale = HasUIScaleComponent and (UIScale:GetAttribute("SavedScale") :: number) or 1

    ui.Visible = true
    self:AnimateScale(UIScale, NewScale, tweenInfo, function()
        if HasUIScaleComponent then
            UIScale:SetAttribute("IsAnimating", false)
        end

        if onCompleted then
            onCompleted()
        end
    end)
end

function UIUtil.CloseUI(self: Module, ui: GuiObject, tweenInfo: TweenInfo?, HasUIScaleComponent: boolean?, onCompleted: () -> ()?)
    local UIScale = ui:FindFirstChildOfClass("UIScale")

    if not UIScale then
        local NewUIScale = Instance.new("UIScale")
        NewUIScale.Parent = ui
        NewUIScale.Scale = 1
        UIScale = NewUIScale
    end

    if not UIScale then
        return
    end

    if HasUIScaleComponent then
        UIScale:SetAttribute("IsAnimating", true)
    end

    local NewScale = 0

    self:AnimateScale(UIScale, NewScale, tweenInfo, function()
        ui.Visible = false

        if HasUIScaleComponent then
            UIScale:SetAttribute("IsAnimating", false)
        end

        if onCompleted then
            onCompleted()
        end
    end)
end

function UIUtil.ForceUIOpen(self: Module, ui: GuiObject, HasUIScaleComponent: boolean?)
    local UIScale = ui:FindFirstChildOfClass("UIScale")
    
    if not UIScale then
        local NewUIScale = Instance.new("UIScale")
        NewUIScale.Parent = ui
        NewUIScale.Scale = 1
        UIScale = NewUIScale
    end

    if not UIScale then
        return
    end

    local NewScale = HasUIScaleComponent and (UIScale:GetAttribute("SavedScale") :: number) or 1

    ui.Visible = true
    self:SetScale(UIScale, NewScale)
end

function UIUtil.ForceUIClose(self: Module, ui: GuiObject)
    local UIScale = ui:FindFirstChildOfClass("UIScale")
    
    if not UIScale then
        local NewUIScale = Instance.new("UIScale")
        NewUIScale.Parent = ui
        NewUIScale.Scale = 1
        UIScale = NewUIScale
    end

    if not UIScale then
        return
    end

    local NewScale = 0

    ui.Visible = false
    self:SetScale(UIScale, NewScale)
end

return UIUtil :: Module
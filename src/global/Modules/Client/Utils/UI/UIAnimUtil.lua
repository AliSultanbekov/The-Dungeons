--[=[
    @class UIAnimUtil
]=]

-- [ Roblox Services ] --
local TweenService = game:GetService("TweenService")

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local DEFAULT_TWEEN = TweenInfo.new(0.1)

-- [ Variables ] --

-- [ Module Table ] --
local UIAnimUtil = {
    Cache = {
        Position = {},
        Scale = {}
    }
}

-- [ Types ] --
export type Module = typeof(UIAnimUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function _CleanUpTween(self: Module, ui: any, cacheType: string)
    local Tween = self.Cache[cacheType][ui]

    if not Tween then
        return
    end

    Tween:Destroy()

    self.Cache[cacheType][ui] = nil
end

function UIAnimUtil.AnimateToPosition(self: Module, ui: GuiObject, value: UDim2, tweenInfo: TweenInfo, onCompleted: () -> ()?)
    _CleanUpTween(self, ui, "Position")

    local Tween = TweenService:Create(ui, tweenInfo, { Position = value })

    self.Cache.Position[ui] = Tween

    Tween.Completed:Connect(function()
        _CleanUpTween(self, ui, "Position")
    end)

    Tween:Play()
end

function UIAnimUtil.AnimateScale(self: Module, uiScale: UIScale, value: number, tweenInfo: TweenInfo?, onCompleted: () -> ()?)
    _CleanUpTween(self, uiScale, "Scale")

    local Tween = TweenService:Create(uiScale, tweenInfo or DEFAULT_TWEEN, { Scale = value })

    self.Cache.Scale[uiScale] = Tween

    Tween.Completed:Connect(function()
        _CleanUpTween(self, uiScale, "Scale")

        if onCompleted then
            onCompleted()
        end
    end)

    Tween:Play()
end

function UIAnimUtil.AnimateUIScale(self: Module, ui: GuiObject, value: number, tweenInfo: TweenInfo, onCompleted: () -> ()?)
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

    self:AnimateScale(UIScale, value, tweenInfo, onCompleted)
end

return UIAnimUtil :: Module
local TweenService = game:GetService("TweenService")
--[=[
    @class CameraAnimUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local DEFAULT_TWEEN = TweenInfo.new(0.1)

-- [ Variables ] --

-- [ Module Table ] --
local CameraAnimUtil = {
    Cache = {
        FOV = {}
    }
}

-- [ Types ] --
export type Module = typeof(CameraAnimUtil)

-- [ Private Functions ] --
function _CleanUpTween(self: Module, camera: Camera, cacheType: string)
    local Tween = self.Cache[cacheType][camera]

    if not Tween then
        return
    end

    Tween:Destroy()

    self.Cache[cacheType][camera] = nil
end

-- [ Public Functions ] --
function CameraAnimUtil.AnimateFOV(self: Module, camera: Camera, value: number, tweenInfo: TweenInfo, onCompleted: () -> ()?)
    _CleanUpTween(self, camera, "FOV")

    local Tween = TweenService:Create(camera, tweenInfo or DEFAULT_TWEEN, { FieldOfView = value })

    self.Cache.FOV[camera] = Tween

    Tween.Completed:Connect(function()
        _CleanUpTween(self, camera, "FOV")

        if onCompleted then
            onCompleted()
        end
    end)

    Tween:Play()
end

return CameraAnimUtil :: Module
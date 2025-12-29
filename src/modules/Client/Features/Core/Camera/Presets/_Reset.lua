local Players = game:GetService("Players")
--[=[
    @class Reset
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Easings = require("Easings")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local Reset = {}

-- [ Types ] --
type CameraController = typeof(require("CameraController"))
export type Module = typeof(Reset)

-- [ Private Functions ] --
function _CheckIfLoaded(player: Player): (Model?, BasePart?, BasePart?)
    local Character = player.Character
    

    if not Character then
        return
    end

    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart

    if not HumanoidRootPart then
        return
    end

    local Head = Character:FindFirstChild("Head") :: BasePart

    if not Head then
        return
    end

    return Character, HumanoidRootPart, Head
end

-- [ Public Functions ] --
function Reset.Start(self: Module, cameraController: CameraController)
    cameraController:TakeOwnership()
    
    local Camera = cameraController:GetCamera()
    local SavePoint = cameraController:GetSavePoint()
    local Character, HumanoidRootPart, Head = _CheckIfLoaded(Player)
    
    if not Character or not HumanoidRootPart or not Head then 
        return 
    end
    
    local Duration = 0.5
    local Elapsed = 0

    local CameraOffset = Camera:GetPivot().Position - Head:GetPivot().Position
    local SavePointOffset = SavePoint.Position - Head:GetPivot().Position

    local CameraRotation = Camera:GetPivot() - Camera:GetPivot().Position
    local SavePointRotation = SavePoint - SavePoint.Position

    cameraController:SetUpdate(function(dt: number)
        local Character, HumanoidRootPart, Head = _CheckIfLoaded(Player)
        
        if not Character or not HumanoidRootPart or not Head then 
            return 
        end

        local StartPos = Head:GetPivot().Position + CameraOffset
        local GoalPos = Head:GetPivot().Position + SavePointOffset

        Elapsed += dt
        local Alpha = math.clamp(Elapsed/Duration, 0, 1)
        local EasedAlpha = Easings:OutQuad(Alpha)

        local PosLerp = StartPos:Lerp(GoalPos, EasedAlpha)
        local RotLerp = CameraRotation:Lerp(SavePointRotation, EasedAlpha)

        Camera:PivotTo(RotLerp + PosLerp)

        if Alpha >= 1 then
            cameraController:TerminatePreset()
        end
    end)
end

return Reset :: Module
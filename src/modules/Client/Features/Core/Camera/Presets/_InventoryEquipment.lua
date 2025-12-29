--[=[
    @class InventoryEquipment
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Easings = require("Easings")

-- [ Constants ] --


-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local InventoryEquipment = {}

-- [ Types ] --
type CameraController = typeof(require("CameraController"))
export type Module = typeof(InventoryEquipment)

-- [ Private Functions ] --
function _CheckIfLoaded(player: Player): (Model?, BasePart?)
    local Character = player.Character
    

    if not Character then
        return nil, nil
    end

    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart

    if not HumanoidRootPart then
        return nil, nil
    end

    return Character, HumanoidRootPart
end

-- [ Public Functions ] --
function InventoryEquipment.Start(self, cameraController: CameraController)
    cameraController:CaptureSavePoint()
    cameraController:TakeOwnership()

    local Camera = cameraController:GetCamera()
    local Character, HumanoidRootPart = _CheckIfLoaded(Player)

    if not Character or not HumanoidRootPart then
        return
    end

    local Duration = 0.5
    local Elapsed = 0

    local Relativity = HumanoidRootPart:GetPivot():ToObjectSpace(Camera:GetPivot())

    cameraController:SetUpdate(function(dt: number)
        local Character, HumanoidRootPart = _CheckIfLoaded(Player)

        if not Character or not HumanoidRootPart then
            return
        end
        
        local NewHRPCF = HumanoidRootPart:GetPivot()
        
        local Start = NewHRPCF * Relativity
        local Goal = CFrame.lookAt((NewHRPCF * CFrame.new(0, 0, -8)).Position, NewHRPCF.Position) * CFrame.new(1.8, 0, 0) * CFrame.Angles(0, math.rad(-20), 0)

        Elapsed += dt
        local Alpha = math.clamp(Elapsed/Duration, 0, 1)
        local EasedAlpha = Easings:OutQuad(Alpha)

        Camera:PivotTo(Start:Lerp(Goal, EasedAlpha))

        if Alpha >= 1 then
            cameraController:SetState("Ready")
        end
    end)
end

return InventoryEquipment :: Module
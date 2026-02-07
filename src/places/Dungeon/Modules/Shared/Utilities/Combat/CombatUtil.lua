--[=[
    @class CombatUtil
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local GeneralGameConstants = require("GeneralGameConstants")

-- [ Constants ] --
local WALKSPEED = 16
local DISTANCE_TOLERANCE = 4
local PING_ADDITIONAL_DELAY = GeneralGameConstants.ProcessingPingDelay

-- [ Variables ] --

-- [ Module Table ] --
local CombatUtil = {}

-- [ Types ] --
type ValidateHit_Context = {
    Attacker: Model,
    Attacked: Model,
    HitboxSize: Vector3,
    Mode: "FromServer"
} | {
    Attacker: Model,
    Attacked: Model,
    PositionHistoryService: typeof(require("PositionHistoryService")),
    ClientAttackerCFrame: CFrame?,
    HitboxSize: Vector3,
    Mode: "FromClient",
}

export type Module = typeof(CombatUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatUtil.ValidateHit(self: Module, context: ValidateHit_Context): boolean
    local Attacker = context.Attacker
    local Attacked = context.Attacked

    local AttackerHitbox = Attacker:FindFirstChild("Hitbox") :: BasePart?
    local AttackedHitbox = Attacked:FindFirstChild("Hitbox") :: BasePart?
    local HitboxSize = context.HitboxSize

    if not AttackerHitbox or not AttackedHitbox then
        return false
    end

    local function validateHitbox(attackerCFrame: CFrame, attackedCFrame: CFrame, ping: number?): boolean
        local Ping = ping or 0
        local Delta = attackedCFrame.Position * Vector3.new(1, 0, 1) - attackerCFrame.Position * Vector3.new(1, 0, 1)

        local PingTolerance = math.max(0, Ping) * WALKSPEED
        local MaxReach = HitboxSize.Z + AttackerHitbox.Size.Z/2 + DISTANCE_TOLERANCE + PingTolerance
        local Distance = Delta.Magnitude

        if MaxReach < Distance then
            warn(string.format("[Validate] REJECT - Out of reach: Distance %.2f > MaxReach %.2f", Distance, MaxReach))
            return false
        end

        local Direction = Delta.Unit
        local FlatDirection = Vector3.new(Direction.X, 0, Direction.Z).Unit

        local AttackerLook = attackerCFrame.LookVector
        local AttackerFlatLook = Vector3.new(AttackerLook.X, 0, AttackerLook.Z).Unit

        if FlatDirection.Magnitude < 1e-6 or AttackerFlatLook.Magnitude < 1e-6 then
            return false
        end
        
        local Dot = AttackerFlatLook:Dot(FlatDirection)

        if Dot < -0.2 then
            print(string.format("[Validate] REJECT - Target behind attacker, Dot: %.2f", Dot))
            return false
        end

        return true
    end
    
    if context.Mode == "FromClient" then
        local Player = Players:GetPlayerFromCharacter(Attacker)

        if not Player then
            return false
        end

        local Ping = PING_ADDITIONAL_DELAY + (Player:GetNetworkPing()/2)
        
        local ClientAttackerCFrame = context.ClientAttackerCFrame

        local CurrentAttackerCFrame = Attacker:GetPivot()
        local RewoundAttackedCFrame = context.PositionHistoryService:GetCFrameAt(Attacked, os.clock() - Ping) or Attacked:GetPivot()

        local AttackerCFrameForValidation: CFrame
        if ClientAttackerCFrame then
            AttackerCFrameForValidation = CFrame.new(CurrentAttackerCFrame.Position) * ClientAttackerCFrame.Rotation
        else
            AttackerCFrameForValidation = CurrentAttackerCFrame
        end

        if not validateHitbox(AttackerCFrameForValidation, RewoundAttackedCFrame, Ping) then
            return false
        end

        return true
    elseif context.Mode == "FromServer" then
        if not validateHitbox(Attacker:GetPivot(), Attacked:GetPivot()) then
            return false
        end

        return true
    end

    return false
end

return CombatUtil :: Module
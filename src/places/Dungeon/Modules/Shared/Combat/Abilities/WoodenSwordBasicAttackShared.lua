local Players = game:GetService("Players")
--[=[
    @class WoodenSwordBasicAttackShared
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local _WeaponConfig = require("WeaponConfig")
local HitboxClass = require("HitboxClass")

-- [ Constants ] --
local BASE_DISTANCE_TOLERANCE = 3
local BASE_ANGLE_TOLERANCE = 0.15

-- [ Variables ] --

-- [ Module Table ] --
local WoodenSwordBasicAttackShared = {}

-- [ Types ] --
type DetectHits_Context = {
    Attacker: Model, 
    Config: Config
}
type Validate_Context = {
    Attacker: Model,
    Config: Config,
    Hits: { Model }
}
type Config = {
    Range: number,
    MinDot: number,
    Animation: string,
    Name: string,
    Damage: number,
}
export type Module = typeof(WoodenSwordBasicAttackShared)

-- [ Private Functions ] --
function WoodenSwordBasicAttackShared._GetTolerance(self: Module, character: Model): (number?, number?)
    local Player = Players:GetPlayerFromCharacter(character)

    if not Player then
        return
    end

    local Ping = Player:GetNetworkPing() * 1000

    print(Ping)

    local Distance = math.min(Ping/100, 2)
    local Angle = math.min(Ping/1000, 0.2)

    return Distance, Angle
end

-- [ Public Functions ] --
function WoodenSwordBasicAttackShared.DetectHits(self: Module, context: DetectHits_Context)
    local Attacker = context.Attacker
    local Config = context.Config

    local HRP = Attacker:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not HRP then
        return
    end

    print(Attacker:GetPivot().Position)

    local HitboxObject = HitboxClass.new({
        HitboxClassType = "Box",
        GetCFrame = function()
            local RootCFrame = HRP:GetPivot()
            local Position = RootCFrame.Position
            local _, y, _ = RootCFrame:ToEulerAnglesYXZ()
            local FlatCFrame = CFrame.new(Position) * CFrame.Angles(0, y, 0)
            return FlatCFrame * CFrame.new(0, 0, -(HRP.Size.Z/2 + Config.Range/2))
        end,
        Size = Vector3.new(3,3,Config.Range),
        Visualise = true,
        Ignore = {
            Attacker
        }
    })

    local Hits = HitboxObject:Trigger()

    return Hits
end

function WoodenSwordBasicAttackShared.Validate(self: Module, context: Validate_Context)
    local Attacker = context.Attacker
    local Config = context.Config
    local Hits = context.Hits

    local AttackerHRP = Attacker:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not AttackerHRP then
        table.clear(Hits)
        return
    end

    print(Attacker:GetPivot().Position)

    local DistanceTolerance, AngleTolerance = self:_GetTolerance(Attacker)

    for i = #Hits, 1, -1 do
        local Attacked = Hits[i]
        local AttackedHRP = Attacked:FindFirstChild("HumanoidRootPart") :: BasePart?

        if not AttackedHRP then
            table.remove(context.Hits, i)
            continue
        end
        
        local delta = Attacked:GetPivot().Position - Attacker:GetPivot().Position
        local CenterDistance = delta.Magnitude
        local Direction = delta.Unit

        local AttackedRadius = math.max(AttackedHRP.Size.X, AttackedHRP.Size.Z)/2
        local EffectiveDistance = CenterDistance - AttackedRadius
        local MaxAllowedDistance = Config.Range + BASE_DISTANCE_TOLERANCE + (DistanceTolerance or 0)

        print("Distance - Effective:", EffectiveDistance, "Max:", MaxAllowedDistance)

        if EffectiveDistance > MaxAllowedDistance then
            table.remove(context.Hits, i)
            continue
        end
        
        local AttackerLookVec = Attacker:GetPivot().lookVector
        local FlatLook = Vector3.new(AttackerLookVec.X, 0, AttackerLookVec.Z).Unit
        local FlatDir = Vector3.new(Direction.X, 0, Direction.Z).Unit
        local Dot = FlatLook:Dot(FlatDir)
        local MinRequiredDot = Config.MinDot + BASE_ANGLE_TOLERANCE - (AngleTolerance or 0)

        print("Angle - Dot:", Dot, "Min:", MinRequiredDot)

        if Dot < MinRequiredDot then
            table.remove(context.Hits, i)
            continue
        end
    end
end

return WoodenSwordBasicAttackShared :: Module
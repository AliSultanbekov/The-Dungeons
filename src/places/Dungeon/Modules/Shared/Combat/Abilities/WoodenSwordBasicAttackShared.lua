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
local _VectorUtil = require("VectorUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WoodenSwordBasicAttackShared = {}

-- [ Types ] --
type DetectHits_Context = {
    Attacker: Model, 
    OnHit: (hitCharacter: Model) -> (),
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

-- [ Public Functions ] --
function WoodenSwordBasicAttackShared.DetectHits(self: Module, context: DetectHits_Context)
    local Attacker = context.Attacker
    local OnHit = context.OnHit
    local Config = context.Config

    local HRP = Attacker:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not HRP then
        return
    end

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
        Length = 2/60,
        Cb = function(hitCharacter)
            OnHit(hitCharacter)
        end,
        Visualise = true,
        Ignore = {
            Attacker
        }
    })
    HitboxObject:Trigger()
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

        local AttackedRadius = math.max(AttackedHRP.Size.X, AttackedHRP.Size.Z)
        local EffectiveDistance = CenterDistance - AttackedRadius
    
        if EffectiveDistance > Config.Range then
            table.remove(context.Hits, i)
            continue
        end
        
        local AttackerLookVec = Attacker:GetPivot().lookVector
        local FlatLook = Vector3.new(AttackerLookVec.X, 0, AttackerLookVec.Z).Unit
        local FlatDir = Vector3.new(Direction.X, 0, Direction.Z).Unit
        local Dot = FlatLook:Dot(FlatDir)

        if Dot < Config.MinDot then
            table.remove(context.Hits, i)
            continue
        end
    end
end

return WoodenSwordBasicAttackShared :: Module
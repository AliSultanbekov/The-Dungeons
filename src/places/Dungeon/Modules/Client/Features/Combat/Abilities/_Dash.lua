--[=[
    @class Dash
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local CombatTypes = require("CombatTypes")
local ItemTypes = require("ItemTypes")
local ServiceBag = require("ServiceBag")
local AnimatorClass = require("AnimatorClass")
local TimeUtil = require("TimeUtil")
local AbilityConfig = require("AbilityConfig")
local CharacterUtil = require("CharacterUtil")
local AnimationConstants = require("AnimationConstants")
local VFXClass = require("VFXClass")
local VFXContainer = require("VFXContainer")

-- [ Constants ] --
local DashAbilityConfigData = AbilityConfig.Abilities["Dash"]

-- [ Variables ] --

-- [ Module Table ] --
local Dash = {
    AbilityName = "Dash"
}
Dash.__index = Dash

-- [ Types ] --
type End_Context = {
    Mode: CombatTypes.Mode
}
type Use_Context = {
    Mode: CombatTypes.Mode
}
type New_Context = {
    Attacker: Model,
    ItemData: ItemTypes.WeaponItemData,
    ServiceBag: ServiceBag.ServiceBag,

    OnUse: (context: CombatTypes.Context) -> (),
    OnEnd: (context: CombatTypes.Context) -> (),
    OnHit: (context: CombatTypes.Context) -> (),
}
export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CreatureServiceClient: typeof(require("CreatureServiceClient")),
    _EntityServiceClient: typeof(require("EntityServiceClient")),

    _Attacker: Model,
    _WeaponData: ItemTypes.WeaponItemData,
    _AnimationObject: AnimatorClass.Object,

    _OnUse: (context: CombatTypes.Context) -> (),
    _OnEnd: (context: CombatTypes.Context) -> (),
    _OnHit: (context: CombatTypes.Context) -> (),

    AbilityName: string
}
export type Object = typeof(setmetatable({} :: ObjectData, Dash))
export type Module = typeof(Dash)

-- [ Private Functions ] --
function Dash._SetupAnimations(self: Object)
    local AnimationObject = self._AnimationObject
    
    AnimationObject:LoadAnimation("DashForward", DashAbilityConfigData.ForwardAnimationID)
    AnimationObject:LoadAnimation("DashBackward", DashAbilityConfigData.BackwardAnimationID)
    AnimationObject:LoadAnimation("DashRight", DashAbilityConfigData.RightAnimationID)
    AnimationObject:LoadAnimation("DashLeft", DashAbilityConfigData.LeftAnimationID)

    AnimationObject:MarkerReachedSignal("DashForward", "End"):Connect(function()
        self:End({Mode = "FromClient"})
    end)

    AnimationObject:MarkerReachedSignal("DashBackward", "End"):Connect(function()
        self:End({Mode = "FromClient"})
    end)
    
    AnimationObject:MarkerReachedSignal("DashRight", "End"):Connect(function()
        self:End({Mode = "FromClient"})
    end)

    AnimationObject:MarkerReachedSignal("DashLeft", "End"):Connect(function()
        self:End({Mode = "FromClient"})
    end)
end

-- [ Public Functions ] --
function Dash.new(context: New_Context): Object
    local self = setmetatable({} :: any, Dash) :: Object

    self._ServiceBag = context.ServiceBag
    self._CreatureServiceClient = self._ServiceBag:GetService(require("CreatureServiceClient"))
    self._EntityServiceClient = self._ServiceBag:GetService(require("EntityServiceClient"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._AnimationObject = self._CreatureServiceClient:GetAnimationObject(self._Attacker)

    self._OnUse = context.OnUse
    self._OnEnd = context.OnEnd
    self._OnHit = context.OnHit

    self:_SetupAnimations()

    return self
end

function Dash.Use(self: Object, context: Use_Context)
    local HumanoidRootPart = self._Attacker:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not HumanoidRootPart then
        return
    end

    local Humanoid = self._Attacker:FindFirstChild("Humanoid") :: Humanoid?

    if not Humanoid then
        return
    end


    if context.Mode == "FromClient" then
        local ServerTime = TimeUtil:GetTime()

        if not self._CreatureServiceClient:UseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = DashAbilityConfigData.Duration,
        }) then
            return
        end

        self._OnUse({
            AbilityName = self.AbilityName
        })

        local LookVec = self._Attacker:GetPivot().LookVector
        local RightVec = self._Attacker:GetPivot().RightVector
        local FlatLookVec = Vector3.new(LookVec.X, 0, LookVec.Z).Unit
        local FlatRightVec = Vector3.new(RightVec.X, 0, RightVec.Z).Unit

        local MoveDir = Humanoid.MoveDirection.Magnitude > 0.1 and Humanoid.MoveDirection or FlatLookVec

        local Forward = FlatLookVec:Dot(MoveDir)
        local Lateral = FlatRightVec:Dot(MoveDir)

        local VFXCFrame = CFrame.new()

        if math.abs(Forward) > math.abs(Lateral) then
            if Forward > 0 then
                self._AnimationObject:PlayAnimation("DashForward", AnimationConstants.CreatureLayers.Combat)
            else
                VFXCFrame = CFrame.new() * CFrame.Angles(0, math.rad(180), 0)
                self._AnimationObject:PlayAnimation("DashBackward", AnimationConstants.CreatureLayers.Combat)
            end
        else
            if Lateral > 0 then
                VFXCFrame = CFrame.new() * CFrame.Angles(0, math.rad(90), 0)
                self._AnimationObject:PlayAnimation("DashRight", AnimationConstants.CreatureLayers.Combat)
            else
                VFXCFrame = CFrame.new() * CFrame.Angles(0, math.rad(-90), 0)
                self._AnimationObject:PlayAnimation("DashLeft", AnimationConstants.CreatureLayers.Combat)
            end
        end

        VFXClass.new({"VFX/Dash/Default"}, HumanoidRootPart, { Cleanup = 2 }):Emit()
        VFXClass.new({"VFX/Dash/Attachment"}, VFXContainer:FromAttachment(HumanoidRootPart, VFXCFrame), { Cleanup = 2 }):Emit()

        CharacterUtil:SetBodyPartsMass(self._Attacker, true)

        self._CreatureServiceClient:ApplyLinearVelocityOnCreature(
            self._Attacker, 
            {
                Mode = "Plane",
                StartTime = ServerTime,
                StartSpeed = 50,
                Duration = 0.15,
                GetDirection = function()
                    local AttackerCFrame = self._Attacker:GetPivot()
                    local LookVec_ = AttackerCFrame.LookVector
                    local MoveDir_ = Humanoid.MoveDirection.Magnitude > 0.1 and Humanoid.MoveDirection or LookVec_
                    local MoveDir2D = Vector2.new(MoveDir_.X, MoveDir_.Z)
                    return MoveDir2D
                end,
                Curve = "Linear"
            },
            {
                Mode = "Plane",
                ForceLimitMode = Enum.ForceLimitMode.Magnitude,
                MaxForce = 10000,
                ForceLimitsEnabled = true,
                RelativeTo = Enum.ActuatorRelativeTo.World,
                PlaneVelocity = Vector2.new(0,0),
                PrimaryTangentAxis = Vector3.new(1,0,0),
                SecondaryTangentAxis = Vector3.new(0,0,1),
            }
        )

        task.delay(0.25, function()
            CharacterUtil:SetBodyPartsMass(self._Attacker, false)
        end)
    end
end

function Dash.End(self: Object, context: End_Context)
    if context.Mode == "FromClient" then
        if not self._CreatureServiceClient:EndAbility(self._Attacker, self.AbilityName) then
            return
        end

        self._CreatureServiceClient:StartAbilityCooldown(self._Attacker, self.AbilityName)

        self._OnEnd({
            AbilityName = self.AbilityName
        })
    elseif context.Mode == "FromServer" then

    end
end

return Dash :: Module
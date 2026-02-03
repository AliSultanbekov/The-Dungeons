--[=[
    @class DefaultBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local AbilityEffectManager = require("../_AbilityEffectManager")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local CombatTypes = require("CombatTypes")
local HitboxClass = require("HitboxClass")
local ItemTypes = require("ItemTypes")
local WeaponConfig = require("WeaponConfig")
local EntityTypesShared = require("EntityTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DefaultBasicAttack = {
    AbilityName = "DefaultBasicAttack"
}
DefaultBasicAttack.__index = DefaultBasicAttack

-- [ Types ] --
type Config = {
    AbilityName: string,
    ComboTimeout: number,
    Combo: { 
        [number]: {
            Animation: string,
            Damage: number,
            Range: Vector3,
            Angle: number,
            Duration: number,
            CommitTime: number
        }
    }
}
type WeaponItemData = ItemTypes.WeaponItemData
type Use_Context = {
    Attacker: Model,
    Mode: "FromServer" | "FromClient",

    OnUse: (context: CombatTypes.Context) -> (),
    OnEnd: (context: CombatTypes.Context) -> (),
    OnHit: (context: CombatTypes.Context) -> (),
}
type Hit_Context = {
    Attacker: Model,
    Attacked: Model,
    Mode: "FromClient",
    OnHit: (context: CombatTypes.Context) -> (),
} | {
    Attacker: Model,
    Attacked: Model,
    HitInfo: "Hit" | "Blocked" | "Parried" | string,
    Mode: "FromServer",
    OnHit: (context: CombatTypes.Context) -> (),
}
type New_Context = {
    Attacker: Model,
    ItemData: WeaponItemData,
    ServiceBag: ServiceBag.ServiceBag,
}
export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CreatureServiceClient: typeof(require("CreatureServiceClient")),

    _Attacker: Model,
    _WeaponData: WeaponItemData,
    _Config: Config,
    _Animations: {},
    _ActiveTrack: AnimationTrack?,
    _ComboTimeoutThread: thread?,
    AbilityName: string,
}
export type Object = typeof(setmetatable({} :: ObjectData, DefaultBasicAttack))
export type Module = typeof(DefaultBasicAttack)

-- [ Private Functions ] --
function DefaultBasicAttack._StartCooldown(self: Object)
    self._CreatureServiceClient:StartAbilityCooldown(self._Attacker, self.AbilityName)
end

-- [ Public Functions ] --
function DefaultBasicAttack.new(context: New_Context): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object

    self._ServiceBag = context.ServiceBag
    self._CreatureServiceClient = self._ServiceBag:GetService(require("CreatureServiceClient"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack
    self._Animations = {}
    self._ActiveTrack = nil
    
    return self
end

function DefaultBasicAttack.Use(self: Object, context: Use_Context)
    local Config = self._Config
    local ComboData = Config.Combo

    local Attacker = self._Attacker
    local Humanoid = Attacker:FindFirstChildOfClass("Humanoid")
    
    if not Humanoid then
        return
    end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")

    if not Animator then
        return
    end

    local HRP = Attacker:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not HRP then
        return
    end

    if context.Mode == "FromClient" then
        print("Useed")
        local PreviousAbility = self._CreatureServiceClient:GetPreviousAbility(self._Attacker) :: EntityTypesShared.ComboAbilityComponent
        local ServerTime = workspace.DistributedGameTime
        local Combo = 1

        if PreviousAbility 
        and PreviousAbility.AbilityName == self.AbilityName 
        and PreviousAbility.StartTime + PreviousAbility.Duration + Config.ComboTimeout >= ServerTime
        and PreviousAbility.Combo < #ComboData then
            Combo += PreviousAbility.Combo
        end

        if not self._CreatureServiceClient:UseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = ComboData[Combo].Duration,
            CommitTime = ComboData[Combo].CommitTime,
            Combo = Combo,
        }) then
            return
        end

        print("OnUSe")

        context.OnUse({
            AbilityName = self.AbilityName,
        })

        local CurrentAbilityData = ComboData[Combo]
        local AnimationID = CurrentAbilityData.Animation
        local Track = self._Animations[AnimationID]

        if not Track then
            local AnimationInstance = Instance.new("Animation"); AnimationInstance.AnimationId = AnimationID
            Track = Animator:LoadAnimation(AnimationInstance)

            self._Animations[AnimationID] = Track

            Track:GetMarkerReachedSignal("Hit"):Connect(function()
                HitboxClass.new({
                    HitboxType = "Box",
                    GetCFrame = function()
                        local BaseCF = Attacker:GetPivot()
                        local LookVec = BaseCF.LookVector
                        local FlatLooKVec = Vector3.new(LookVec.X, 0, LookVec.Z)
    
                        if FlatLooKVec.Magnitude < 1e-6 then
                            return CFrame.identity
                        end
    
                        return CFrame.lookAt(BaseCF.Position, BaseCF.Position + FlatLooKVec) * CFrame.new(0, 0, -(HRP.Size.Z/2 + CurrentAbilityData.Range.Z/2))
                    end,
                    Size = CurrentAbilityData.Range,
                    Length = 4,
                    Ignore = { self._Attacker },
                    Visualise = true,
                    Cb = function(Attacked: Model)
                        self:Hit({
                            Attacker = self._Attacker,
                            Attacked = Attacked,
                            Mode = "FromClient",
                            OnHit = context.OnHit,
                        })
                    end
                }):Trigger()
            end)
        end

        if self._ActiveTrack then
            self._ActiveTrack:Stop()
        end

        task.delay(CurrentAbilityData.Duration, function()
            self:End({
                Mode = context.Mode,
                OnEnd = context.OnEnd
            })
        end)

        self._ActiveTrack = Track

        Track:Play(0, 1, 1)
    end
end

function DefaultBasicAttack.End(self: Object, context: any)
    if context.Mode == "FromClient" then
        if not self._CreatureServiceClient:EndAbility(self._Attacker, "DefaultBasicAttack") then
            return
        end

        context.OnEnd({
            AbilityName = self.AbilityName,
        })

        local PreviousAbility = self._CreatureServiceClient:GetPreviousAbility(self._Attacker) :: EntityTypesShared.ComboAbilityComponent
        local MaxCombo = #self._Config.Combo
        local PreviousAbilityCombo = PreviousAbility.Combo

        if MaxCombo == PreviousAbilityCombo then
            self:_StartCooldown()
        end
    end
end

function DefaultBasicAttack.Hit(self: Object, context: Hit_Context)
    if context.Mode == "FromClient" then
        if not self._CreatureServiceClient:IsAbilityActive(self._Attacker, self.AbilityName) then
            return
        end

        context.OnHit({ 
            AbilityName = self.AbilityName,
            Attacked = context.Attacked,
            AttackerCFrame = context.Attacker:GetPivot()
        })
    elseif context.Mode == "FromServer" then
        AbilityEffectManager:CreateHitEffect(context.Attacked, context.HitInfo)
    end
end

return DefaultBasicAttack :: Module
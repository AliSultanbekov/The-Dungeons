local Players = game:GetService("Players")
--[=[
    @class DefaultBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local AbilityEffectManager = require("../_AbilityEffectManager")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local TimeUtil = require("TimeUtil")
local ItemTypes = require("ItemTypes")
local ServiceBag = require("ServiceBag")
local HitboxClass = require("HitboxClass")
local CombatTypes = require("CombatTypes")
local WeaponConfig = require("WeaponConfig")
local AnimationClass = require("AnimationClass")
local EntityTypesClient = require("EntityTypesClient")
local AnimationConstants = require("AnimationConstants")
local GeneralGameConstants = require("GeneralGameConstants")

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
            AnimationID: string,
            Damage: number,
            Range: Vector3,
            Angle: number,
            Duration: number,
            CommitTime: number
        }
    }
}

type Hit_Context = {
    Mode: "FromClient",
    Attacked: Model,
} | {
    Mode: "FromServer",
    Attacked: Model,
    HitInfo: string,
}
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

    _Attacker: Model,
    _WeaponData: ItemTypes.WeaponItemData,
    _Config: Config,
    _AnimationObject: AnimationClass.Object,

    _OnUse: (context: CombatTypes.Context) -> (),
    _OnEnd: (context: CombatTypes.Context) -> (),
    _OnHit: (context: CombatTypes.Context) -> (),

    AbilityName: string
}
export type Object = typeof(setmetatable({} :: ObjectData, DefaultBasicAttack))
export type Module = typeof(DefaultBasicAttack)

-- [ Private Functions ] --
function DefaultBasicAttack._GetAnimationName(self: Object, comboNumber: number)
    return string.format("%s/%d", self.AbilityName, comboNumber)
end

function DefaultBasicAttack._SetupAnimations(self: Object)
    local Config = self._Config
    local AnimationObject = self._AnimationObject
    
    for i, comboData in Config.Combo do
        local AnimationName = string.format("%s/%d", self.AbilityName, i)
        AnimationObject:LoadAnimation(AnimationName, comboData.AnimationID)

        AnimationObject:MarkerReachedSignal(AnimationName, "Hit"):Connect(function()  
            self:_OnHitMarker()
        end)

        AnimationObject:MarkerReachedSignal(AnimationName, "End"):Connect(function()
            self:End({
                Mode = "FromClient"
            })
        end)
    end
end

function DefaultBasicAttack._StartCooldown(self: Object)
    self._CreatureServiceClient:StartAbilityCooldown(self._Attacker, self.AbilityName)
end

function DefaultBasicAttack._OnHitMarker(self: Object)
    local CurrentAbility = self._CreatureServiceClient:GetCurrentAbility(self._Attacker, self.AbilityName) :: EntityTypesClient.ComboAbility

    if not CurrentAbility then
        return
    end

    local Config = self._Config
    local Combo = CurrentAbility.Combo
    local ComboData = Config.Combo[Combo]

    HitboxClass.new({
        HitboxType = "Box",
        GetCFrame = function()
            local HRP = self._Attacker:FindFirstChild("HumanoidRootPart") :: BasePart?

            if not HRP then
                return CFrame.identity
            end

            local BaseCF = self._Attacker:GetPivot()
            local LookVec = BaseCF.LookVector
            local FlatLooKVec = Vector3.new(LookVec.X, 0, LookVec.Z)

            if FlatLooKVec.Magnitude < 1e-6 then
                return CFrame.identity
            end

            return CFrame.lookAt(BaseCF.Position, BaseCF.Position + FlatLooKVec) * CFrame.new(0, 0, -(HRP.Size.Z/2 + ComboData.Range.Z/2))
        end,
        Size = ComboData.Range,
        Length = 4,
        Ignore = { self._Attacker },
        Visualise = true,
        Cb = function(Attacked: Model)
            if not self._CreatureServiceClient:IsAbilityActive(self._Attacker) then
                return
            end

            self:Hit({
                Mode = "FromClient",
                Attacked = Attacked
            })
        end
    }):Trigger()
end

-- [ Public Functions ] --
function DefaultBasicAttack.new(context: New_Context): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object

    self._ServiceBag = context.ServiceBag
    self._CreatureServiceClient = self._ServiceBag:GetService(require("CreatureServiceClient"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack
    self._AnimationObject = self._CreatureServiceClient:GetAnimationObject(self._Attacker)

    self._OnUse = context.OnUse
    self._OnEnd = context.OnEnd
    self._OnHit = context.OnHit

    self:_SetupAnimations()

    return self
end

function DefaultBasicAttack.Use(self: Object, context: Use_Context)
    if context.Mode == "FromClient" then

        local Config = self._Config
        local ComboData = Config.Combo
        local PreviousAbility = self._CreatureServiceClient:GetPreviousAbility(self._Attacker, self.AbilityName) :: EntityTypesClient.ComboAbility
        local ServerTime = TimeUtil:GetTime()
        local Combo = 1

        if PreviousAbility 
        and PreviousAbility.AbilityName == self.AbilityName 
        and PreviousAbility.StartTime + PreviousAbility.Duration + Config.ComboTimeout >= ServerTime
        and PreviousAbility.Combo < #ComboData then
            Combo += PreviousAbility.Combo
        end

        if not self._CreatureServiceClient:UseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime + GeneralGameConstants.ProcessingPingDelay,
            Duration = ComboData[Combo].Duration,
            CommitTime = ComboData[Combo].CommitTime,
            Combo = Combo,
        }) then
            return
        end

        print(ServerTime)

        self._OnUse({
            AbilityName = self.AbilityName
        })

        self._AnimationObject:PlayAnimation(self:_GetAnimationName(Combo), AnimationConstants.CreatureLayers.Combat)
    elseif context.Mode == "FromServer" then
        
    end
end

function DefaultBasicAttack.End(self: Object, context: End_Context)
    if context.Mode == "FromClient" then
        if not self._CreatureServiceClient:EndAbility(self._Attacker, "DefaultBasicAttack") then
            return
        end

        self._OnEnd({
            AbilityName = self.AbilityName
        })

        local PreviousAbility = self._CreatureServiceClient:GetPreviousAbility(self._Attacker, self.AbilityName) :: EntityTypesClient.ComboAbility
        local MaxCombo = #self._Config.Combo
        local PreviousAbilityCombo = PreviousAbility.Combo

        if MaxCombo == PreviousAbilityCombo then
            self:_StartCooldown()
        end
    elseif context.Mode == "FromServer" then
        
    end
end

function DefaultBasicAttack.Hit(self: Object, context: Hit_Context)
    if context.Mode == "FromClient" then
        if not self._CreatureServiceClient:IsAbilityActive(self._Attacker) then
            return
        end

        self._OnHit({
            AbilityName = self.AbilityName,
            Attacked = context.Attacked,
            AttackerCFrame = self._Attacker:GetPivot()
        })
    elseif context.Mode == "FromServer" then
        AbilityEffectManager:CreateHitEffect(context.Attacked, context.HitInfo)
    end
end

return DefaultBasicAttack :: Module
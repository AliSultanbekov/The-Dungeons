--[=[
    @class DefaultBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local CombatTypes = require("CombatTypes")
local HitboxClass = require("HitboxClass")
local ItemTypes = require("ItemTypes")
local WeaponConfig = require("WeaponConfig")
local AssetProvider = require("AssetProvider")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DefaultBasicAttack = {
    AbilityName = "DefaultBasicAttack"
}
DefaultBasicAttack.__index = DefaultBasicAttack

-- [ Types ] --
type AbilityState = {
    Name: string,
    StartTime: number,
    Combo: number,
    Duration: number,
}
type CombatEntityStateService = typeof(require("CombatEntityStateServiceClient"))
type Config = {
    AbilityName: string,
    MaxDelay: number,
    Combo: { 
        [number]: {
            Animation: string,
            Damage: number,
            Range: Vector3,
            Angle: number,
            Time: number
        }
    }
}
type WeaponItemData = ItemTypes.WeaponItemData
type UpdateState_Context = {
    State: {[string]: any}
}
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
}
type New_Context = {
    Attacker: Model,
    ItemData: WeaponItemData,
    CombatEntityStateService: CombatEntityStateService,
}
type AbilityObject = CombatTypes.ClientAbilityObject
export type ObjectData = {
    _CombatEntityStateService: CombatEntityStateService,
    _Attacker: Model,
    _WeaponData: WeaponItemData,
    _Config: Config,
    AbilityName: string,
}
export type Object = typeof(setmetatable({} :: ObjectData, DefaultBasicAttack))
export type Module = typeof(DefaultBasicAttack)

-- [ Private Functions ] --
function DefaultBasicAttack.IsActive(self: Object): boolean
    local CurrentAbility = self._CombatEntityStateService:GetCurrentAbility(self._Attacker) :: AbilityState?

    if not CurrentAbility then
        return false
    end

    if CurrentAbility.Name ~= self.AbilityName then
        return false
    end

    return true
end
-- [ Public Functions ] --
function DefaultBasicAttack.new(context: New_Context): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object
    
    self._CombatEntityStateService = context.CombatEntityStateService

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack
    
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
        print("Used at: " .. os.clock())
        local PreviousAbility = self._CombatEntityStateService:GetPreviousAbility(self._Attacker) :: AbilityState?

        if self:IsActive() then
            return
        end
    
        local Combo = 1

        if PreviousAbility 
        and PreviousAbility.Name == self.AbilityName 
        and PreviousAbility.StartTime + PreviousAbility.Duration + Config.MaxDelay >= os.clock() 
        and PreviousAbility.Combo < #ComboData then
            Combo += PreviousAbility.Combo
            self._CombatEntityStateService:SetCurrentAbility(self._Attacker, {
                Name = self.AbilityName,
                StartTime = os.clock(),
                Duration = ComboData[Combo].Time,
                Combo = Combo,
            })
        else
            self._CombatEntityStateService:SetCurrentAbility(self._Attacker, {
                Name = self.AbilityName,
                StartTime = os.clock(),
                Duration = ComboData[Combo].Time,
                Combo = Combo,
            })
        end

        context.OnUse({
            AbilityName = self.AbilityName,
        })

        local CurrentAbilityData = ComboData[Combo]
        local AnimationID = CurrentAbilityData.Animation
        local AnimationInstance = Instance.new("Animation"); AnimationInstance.AnimationId = AnimationID
        local Track = Animator:LoadAnimation(AnimationInstance)
        Track.Priority = Enum.AnimationPriority.Action
        Track:Play(0, 1, 1)
        Track:GetMarkerReachedSignal("Hit"):Connect(function()
            HitboxClass.new(
                {
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
                    Cb = function(hitCharacter: Model)
                        context.OnHit({ 
                            AbilityName = self.AbilityName,
                            Attacked = hitCharacter, 
                            AttackerCFrame = Attacker:GetPivot() 
                        })
                        
                        self:Hit({
                            Attacker = self._Attacker,
                            Attacked = hitCharacter
                        })
                    end
                }
            ):Trigger()
        end)

        Track:Play()

        task.delay(CurrentAbilityData.Time, function()
            context.OnEnd({
                AbilityName = self.AbilityName,
            })
            self:End()
        end)
    end
end

function DefaultBasicAttack.End(self: Object, context: any)
    self._CombatEntityStateService:SetCurrentAbility(self._Attacker, nil)
end

function DefaultBasicAttack.Hit(self: Object, context: Hit_Context)
    local Sound = AssetProvider:Get(string.format("Sounds/Punches/Punch%d", math.random(1,5))) :: Sound
    Sound.Parent = workspace
    Sound:Play()
    local HitEffectAttachment = context.Attacked:FindFirstChild("HitEffectTest")
    if HitEffectAttachment then
        local Effect = HitEffectAttachment:FindFirstChild("Effect") :: ParticleEmitter

        if Effect then
            Effect:Emit(1)
        end
    end
end

return DefaultBasicAttack :: Module
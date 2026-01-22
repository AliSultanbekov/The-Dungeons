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
local Table = require("Table")
local AssetProvider = require("AssetProvider")

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
    ItemData: WeaponItemData
}
type AbilityObject = CombatTypes.ClientAbilityObject
export type ObjectData = {
    _WeaponData: WeaponItemData,
    _Config: Config,
    _ActiveUntil: number,
    _FirstHitTime: number?,
    _Combo: number,
    AbilityName: string,
}
export type Object = typeof(setmetatable({} :: ObjectData, DefaultBasicAttack))
export type Module = typeof(DefaultBasicAttack)

-- [ Private Functions ] --
function DefaultBasicAttack._IncrementCombo(self: Object)
    if self._Combo == 0 then
        self._FirstHitTime = os.clock()
    end

    self._Combo += 1
end

function DefaultBasicAttack._ResetCombo(self: Object)
    self._Combo = 0
    self._FirstHitTime = nil
end

function DefaultBasicAttack._SetupCombo(self: Object, cb: (comboNumber: number) -> ())
    local Config = self._Config
    local MaxDelay = Config.MaxDelay

    if self._Combo == Table.count(Config.Combo) then
        self:_ResetCombo()
    end

    if self._FirstHitTime then
        if self._FirstHitTime + (MaxDelay * self._Combo) < os.clock() then
            self:_ResetCombo()
        end
    end

    self:_IncrementCombo()

    cb(self._Combo)
end

function DefaultBasicAttack._IsActive(self: Object): boolean
    return self._ActiveUntil >= os.clock()
end
-- [ Public Functions ] --
function DefaultBasicAttack.new(context: New_Context): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object
    self._WeaponData = context.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack

    self._ActiveUntil = 0

    self._FirstHitTime = nil
    self._Combo = 0
    
    return self
end

function DefaultBasicAttack.Use(self: Object, context: Use_Context)
    local Config = self._Config
    local ComboData = Config.Combo

    local Attacker = context.Attacker
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
        if self:_IsActive() then
            return
        end
    
        self._ActiveUntil = math.huge
    
        self:_SetupCombo(function(comboNumber: number)
            print(comboNumber)
            local CurrentAbilityData = ComboData[comboNumber]
    
            context.OnUse({
                AbilityName = self.AbilityName,
            })
    
            self._ActiveUntil = math.huge
    
            task.spawn(function()
                local AnimationID = CurrentAbilityData.Animation
                local AnimationInstance = Instance.new("Animation")
                AnimationInstance.AnimationId = AnimationID
    
                local Track = Animator:LoadAnimation(AnimationInstance)
    
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
                            Ignore = { context.Attacker },
                            Visualise = true,
                            Cb = function(hitCharacter: Model)
                                context.OnHit({ 
                                    AbilityName = self.AbilityName,
                                    Attacked = hitCharacter, 
                                    AttackerCFrame = Attacker:GetPivot() 
                                })
                                
                                self:Hit({
                                    Attacker = context.Attacker,
                                    Attacked = hitCharacter
                                })
                            end
                        }
                    ):Trigger()
    
                    context.OnEnd({
                        AbilityName = self.AbilityName,
                    })

                    self:End()
                end)
    
                Track:Play()
            end)
        end)
    end
end

function DefaultBasicAttack.End(self: Object, context: any)
    self._ActiveUntil = 0
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

function DefaultBasicAttack.UpdateState(self: Object, context: UpdateState_Context)
    self._ActiveUntil = context.State.ActiveUntil
    self._Combo = context.State.Combo
    self._FirstHitTime = context.State.FirstHitTime
end

return DefaultBasicAttack :: Module
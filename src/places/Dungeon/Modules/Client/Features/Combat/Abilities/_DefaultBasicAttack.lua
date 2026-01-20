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
local _AbilityConfig = require("AbilityConfig")
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
type Use_Params = {
    Attacker: Model,
    OnHit: (params: {[any]: any}?) -> (),
    OnUse: (params: {[any]: any}?) -> (),
    OnEnd: (params: {[any]: any}?) -> (),
}
type Hit_Params = {
    Attacker: Model,
    Attacked: Model,
}
type New_Params = {
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
function DefaultBasicAttack.new(params: New_Params): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object
    self._WeaponData = params.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack

    self._ActiveUntil = 0
    
    self._FirstHitTime = nil
    self._Combo = 0
    
    return self
end
function DefaultBasicAttack.Use(self: Object, params: Use_Params)
    local Config = self._Config
    local ComboData = Config.Combo

    local Attacker = params.Attacker
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

    if self:_IsActive() then
        return
    end

    self._ActiveUntil = math.huge

    self:_SetupCombo(function(comboNumber: number)
        local CurrentAbilityData = ComboData[comboNumber]

        params.OnUse()

        self._ActiveUntil = os.clock() + CurrentAbilityData.Time

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
                        Length = 10,
                        Ignore = { params.Attacker },
                        Visualise = true,
                        Cb = function(hitCharacter: Model)
                            params.OnHit({ Attacked = hitCharacter, AttackerCFrame = Attacker:GetPivot() })
                            
                            self:Hit({
                                Attacker = params.Attacker,
                                Attacked = hitCharacter
                            })
                        end
                    }
                ):Trigger()

                params.OnEnd()
            end)

            Track:Play()
        end)
    end)
end

function DefaultBasicAttack.End(self: Object, params: Use_Params)
    
end

function DefaultBasicAttack.Hit(self: Object, params: Hit_Params)
    local Sound = AssetProvider:Get(string.format("Sounds/Punches/Punch%d", math.random(1,5))) :: Sound
    Sound.Parent = workspace
    Sound:Play()
    local HitEffectAttachment = params.Attacked:FindFirstChild("HitEffectTest")
    if HitEffectAttachment then
        local Effect = HitEffectAttachment:FindFirstChild("Effect") :: ParticleEmitter

        if Effect then
            Effect:Emit(1)
        end
    end
end

return DefaultBasicAttack :: Module
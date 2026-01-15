--[=[
    @class DefaultBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local HitboxClass = require("HitboxClass")
local ItemTypes = require("ItemTypes")
local WeaponConfig = require("WeaponConfig")
local _AbilityConfig = require("AbilityConfig")
local Table = require("Table")

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
}
type New_Params = {
    ItemData: WeaponItemData
}
export type ObjectData = {
    _WeaponData: WeaponItemData,
    _Config: Config,
    _Active: boolean,
    _FirstHitTime: number?,
    _Combo: number,
}
export type ModuleData = {
    AbilityName: string,
}
export type Object = ModuleData & ObjectData & {
    _IncrementCombo: (self: Object) -> (),
    _ResetCombo: (self: Object) -> (),
    _SetupCombo: (self: Object, cb: (comboNumber: number) -> ()) -> (),
}
export type Module = ModuleData & {
    __index: Module,
    new: (params: New_Params) -> Object
}

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
-- [ Public Functions ] --
function DefaultBasicAttack.new(params: New_Params): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object
    self._WeaponData = params.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack

    self._Active = false
    
    self._FirstHitTime = nil
    self._Combo = 0
    
    return self
end

function DefaultBasicAttack.Use(self: Object, params: Use_Params)
    if self._Active then
        return
    end

    self._Active = true

    local Config = self._Config
    local ComboData = Config.Combo

    local Attacker = params.Attacker
    local Humanoid = Attacker:FindFirstChildOfClass("Humanoid")
    
    if not Humanoid then
        self._Active = false
        return
    end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")

    if not Animator then
        self._Active = false
        return
    end

    local HRP = Attacker:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not HRP then
        self._Active = false
        return
    end

    self:_SetupCombo(function(comboNumber: number)
        local CurrentAbilityData = ComboData[comboNumber]

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

                            return CFrame.lookAt(BaseCF.Position, BaseCF.Position + FlatLooKVec) * CFrame.new(0, 0, -(HRP.Size.Z/2 + 5/2))
                        end,
                        Size = CurrentAbilityData.Range,
                        Length = 3/60,
                        Ignore = { params.Attacker },
                        Visualise = true,
                        Cb = function(hitCharacter: Model)
                            local HitEffectAttachment = hitCharacter:FindFirstChild("HitEffectTest")
                            if HitEffectAttachment then
                                local Effect = HitEffectAttachment:FindFirstChild("Effect") :: ParticleEmitter

                                if Effect then
                                    Effect:Emit(1)
                                end
                            end

                            params.OnHit({ Attacked = hitCharacter, AttackerCFrame = Attacker:GetPivot() })
                        end
                    }
                ):Trigger()
            end)
        
        params.OnUse()

        Track:Play()

        task.wait(CurrentAbilityData.Time)
        
        self._Active = false
        end)
    end)
end

function DefaultBasicAttack.Apply(self: Object)
    
end

return DefaultBasicAttack :: Module
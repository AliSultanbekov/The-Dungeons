--[=[
    @class DefaultBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local ItemTypes = require("ItemTypes")
local WeaponConfig = require("WeaponConfig")
local Table = require("Table")
local CombatUtil = require("CombatUtil")
local CombatConfig = require("CombatConfig")
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DefaultBasicAttack = {
    AbilityName = "DefaultBasicAttack"
}
DefaultBasicAttack.__index = DefaultBasicAttack

-- [ Types ] --
type PositionHistoryService = typeof(require("PositionHistoryService"))
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
type Use_Context = {
    Attacker: Model,
    OnAbilityStateUpdated: (context: CombatTypes.Context) -> (),
    OnUse: (context: CombatTypes.Context) -> (),
}
type End_Context = {
    Attacker: Model,
    OnAbilityStateUpdated: (context: CombatTypes.Context) -> (),
    OnEnd: (context: CombatTypes.Context) -> (),
}
type Hit_Context = {
    Mode: "FromServer",
    Attacker: Model,
    Attacked: Model,
    OnAbilityStateUpdated: (context: CombatTypes.Context) -> (),
    OnHit: (context: CombatTypes.Context) -> (),
} | {
    Mode: "FromClient",
    Attacker: Model,
    Attacked: Model,
    AttackerCFrame: CFrame,
    OnAbilityStateUpdated: (context: CombatTypes.Context) -> (),
    OnHit: (context: CombatTypes.Context) -> (),
}
type New_Context = {
    ItemData: WeaponItemData,
    PositionHistoryService: PositionHistoryService,
}
type AbilityObject = CombatTypes.AbilityObject
export type ObjectData = {
    _WeaponData: WeaponItemData,
    _PositionHistoryService: PositionHistoryService,
    _Config: Config,
    _ActiveUntil: number,
    _HasEnded: boolean,
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

function DefaultBasicAttack.IsActive(self: Object): boolean
    return self._ActiveUntil >= os.clock()
end

-- [ Public Functions ] --
function DefaultBasicAttack.new(context: New_Context): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object

    self._PositionHistoryService = context.PositionHistoryService

    self._WeaponData = context.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack

    self._ActiveUntil = 0
    self._FirstHitTime = nil
    self._Combo = 0

    self._HasEnded = true

    return self
end

function DefaultBasicAttack.Use(self: Object, context: Use_Context)
    local Config = self._Config
    local ComboData = Config.Combo

    if self:IsActive() and not self._HasEnded then
        print("[Use] REJECTED - expires in", string.format("%.2f", self._ActiveUntil - os.clock()))
        return
    end

    self._HasEnded = false
    self._ActiveUntil = math.huge

    self:_SetupCombo(function(comboNumber: number)
        local CurrentAbilityData = ComboData[comboNumber]
        
        local FALLBACK_BUFFER = 1
        self._ActiveUntil = os.clock() + CurrentAbilityData.Time + FALLBACK_BUFFER
    end)

    context.OnAbilityStateUpdated({
        Attacker = context.Attacker,
        AbilityName = self.AbilityName,
        State = self:GetState()
    })
end

function DefaultBasicAttack.End(self: Object, context: End_Context)
    if not self:IsActive() then
        print("[End] REJECTED - expired", string.format("%.2f", os.clock() - self._ActiveUntil), "s ago")
        return
    end
    
    self._HasEnded = true
    self._ActiveUntil = os.clock() + CombatConfig.EndGracePeriod

    context.OnAbilityStateUpdated({
        Attacker = context.Attacker,
        AbilityName = self.AbilityName,
        State = self:GetState()
    })
end

function DefaultBasicAttack.Hit(self: Object, context: Hit_Context)
    if not self:IsActive() then
        warn("[Apply] REJECTED - ability is no longer active")
        return
    end

    local Config = self._Config
    local Combo = self._Combo
    local CurrentComboData = Config.Combo[Combo]

    if context.Mode == "FromClient" then
        if not CombatUtil:ValidateHit({
            Attacker = context.Attacker,
            Attacked = context.Attacked,
            ClientAttackerCFrame = context.AttackerCFrame,
            PositionHistoryService = self._PositionHistoryService,
            HitboxSize = CurrentComboData.Range,
            Mode = "FromClient",
        }) then
            return false
        end

        context.OnHit({
            Attacker = context.Attacker,
            Attacked = context.Attacked
        })

        context.OnAbilityStateUpdated({
            Attacker = context.Attacker,
            AbilityName = self.AbilityName,
            State = self:GetState()
        })
    else
        
    end

    local Humanoid = context.Attacked:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    if Humanoid.Health < 0 then
        return
    end

    Humanoid.Health -= CurrentComboData.Damage
end

function DefaultBasicAttack.GetState(self: Object)
    return {
        Combo = self._Combo,
        ActiveUntil = self._ActiveUntil,
        FirstHitTime = self._FirstHitTime
    }
end

return DefaultBasicAttack :: Module
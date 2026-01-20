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
type Use_Params = {
    OnUse: (params: {[any]: any}?) -> (),
}
type End_Params = {
    OnEnd: (params: {[any]: any}?) -> (),
}
type Hit_Params = {
    Mode: "FromServer",
    Attacker: Model,
    Attacked: Model,
    OnHit: (params: {[any]: any}?) -> (),
} | {
    Mode: "FromClient",
    Attacker: Model,
    Attacked: Model,
    AttackerCFrame: CFrame,
    OnHit: (params: {[any]: any}?) -> (),
}
type New_Params = {
    ItemData: WeaponItemData,
    PositionHistoryService: PositionHistoryService,
}
type AbilityObject = CombatTypes.ServerAbilityObject
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
function DefaultBasicAttack.new(params: New_Params): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object

    self._PositionHistoryService = params.PositionHistoryService

    self._WeaponData = params.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack

    self._ActiveUntil = 0
    self._HasEnded = true
    self._FirstHitTime = nil
    self._Combo = 0

    return self
end

function DefaultBasicAttack.Use(self: Object, params: Use_Params)
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
end

function DefaultBasicAttack.End(self: Object, params: End_Params)
    if not self:IsActive() then
        print("[End] REJECTED - expired", string.format("%.2f", os.clock() - self._ActiveUntil), "s ago")
        return
    end
    
    self._HasEnded = true
    self._ActiveUntil = os.clock() + CombatConfig.EndGracePeriod
end

function DefaultBasicAttack.Hit(self: Object, params: Hit_Params)
    if not self:IsActive() then
        warn("[Apply] REJECTED - ability is no longer active")
        return
    end

    local Config = self._Config
    local Combo = self._Combo
    local CurrentComboData = Config.Combo[Combo]

    if params.Mode == "FromClient" then
        if not CombatUtil:ValidateHit({
            Attacker = params.Attacker,
            Attacked = params.Attacked,
            ClientAttackerCFrame = params.AttackerCFrame,
            PositionHistoryService = self._PositionHistoryService,
            HitboxSize = CurrentComboData.Range,
            Mode = "FromClient",
        }) then
            return false
        end

        params.OnHit({
            Attacker = params.Attacker,
            Attacked = params.Attacked
        })
    else
        
    end

    local Humanoid = params.Attacked:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    if Humanoid.Health < 0 then
        return
    end

    Humanoid.Health -= CurrentComboData.Damage
end

return DefaultBasicAttack :: Module
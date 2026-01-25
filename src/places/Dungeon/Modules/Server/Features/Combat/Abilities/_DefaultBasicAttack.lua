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
local CombatUtil = require("CombatUtil")
local CombatTypes = require("CombatTypes")

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
type PositionHistoryService = typeof(require("PositionHistoryService"))
type CombatEntityStateService = typeof(require("CombatEntityStateServiceServer"))
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
}
type End_Context = {
}
type Hit_Context = {
    Mode: "FromServer",
    Attacked: Model,
    OnHit: (context: CombatTypes.Context) -> (),
} | {
    Mode: "FromClient",
    Attacked: Model,
    AttackerCFrame: CFrame,
    OnHit: (context: CombatTypes.Context) -> (),
}
type New_Context = {
    Attacker: Model,
    ItemData: WeaponItemData,
    PositionHistoryService: PositionHistoryService,
    CombatEntityStateService: CombatEntityStateService,
}
type AbilityObject = CombatTypes.AbilityObject
export type ObjectData = {
    _PositionHistoryService: PositionHistoryService,
    _CombatEntityStateService: CombatEntityStateService,
    _Attacker: Model,
    _WeaponData: WeaponItemData,
    _Config: Config,
    AbilityName: string,
}
export type Object = typeof(setmetatable({} :: ObjectData, DefaultBasicAttack))
export type Module = typeof(DefaultBasicAttack)

-- [ Private Functions ] --

-- [ Public Functions ] --
function DefaultBasicAttack.new(context: New_Context): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object

    self._PositionHistoryService = context.PositionHistoryService
    self._CombatEntityStateService = context.CombatEntityStateService

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack

    return self
end

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

function DefaultBasicAttack.Use(self: Object, context: Use_Context)
    local PreviousAbility = self._CombatEntityStateService:GetPreviousAbility(self._Attacker) :: AbilityState?

    if self:IsActive() then
        return
    end

    local Config = self._Config
    local ComboData = Config.Combo
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
end

function DefaultBasicAttack.End(self: Object, context: End_Context)
    if not self:IsActive() then
        return
    end

    self._CombatEntityStateService:SetCurrentAbility(self._Attacker, nil)
end

function DefaultBasicAttack.Hit(self: Object, context: Hit_Context)
    local CurrentAbility = self._CombatEntityStateService:GetCurrentAbility(self._Attacker) :: AbilityState?

    if not self:IsActive() or not CurrentAbility then
        return
    end

    local Config = self._Config
    local Combo = CurrentAbility.Combo
    local CurrentComboData = Config.Combo[Combo]

    if context.Mode == "FromClient" then
        if not CombatUtil:ValidateHit({
            Attacker = self._Attacker,
            Attacked = context.Attacked,
            ClientAttackerCFrame = context.AttackerCFrame,
            PositionHistoryService = self._PositionHistoryService,
            HitboxSize = CurrentComboData.Range,
            Mode = "FromClient",
        }) then
            return false
        end

        context.OnHit({
            Attacker = self._Attacker,
            Attacked = context.Attacked
        })
    else
        
    end

    local Humanoid = context.Attacked:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    self._CombatEntityStateService:DamageEntity(self._Attacker, context.Attacked, CurrentComboData.Damage)
end

return DefaultBasicAttack :: Module
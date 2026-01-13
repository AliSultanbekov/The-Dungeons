--[=[
    @class CombatClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local AbilityManager = require("./_AbilityManager")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local CombatTypes = require("CombatTypes")
local WeaponConfig = require("WeaponConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatClass = {}
CombatClass.__index = CombatClass

-- [ Types ] --
type UseBasicAttack_Context = {
    Hits: { Model }
}
type AbilityObject = CombatTypes.ServerAbilityObject
type AbilityManagerObject = AbilityManager.Object
export type ObjectData = {
    _Character: Model,
    _AbilityManager: AbilityManagerObject,

    _BasicAttack: AbilityObject?,
    _SpecialAttack: AbilityObject?,
}
export type Object = ObjectData & {
    SetActiveWeapon: (self: Object, weaponName: string?) -> (),
    UseBasicAttack: (self: Object, context: UseBasicAttack_Context) -> (),
    UseSpecialAttack: (self: Object) -> (),
}
export type Module = {
    __index: Module,
    new: (character: Model, abilityManager: AbilityManagerObject) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatClass.new(character: Model, abilityManager: AbilityManagerObject): Object
    local self = setmetatable({} :: any, CombatClass) :: Object

    self._Character = character
    self._AbilityManager = abilityManager

    self._BasicAttack = nil
    self._SpecialAttack = nil

    return self
end

function CombatClass.SetActiveWeapon(self: Object, weaponName: string?)
    if not weaponName then
        self._BasicAttack = nil
        self._SpecialAttack = nil
    else
        local BasicAttackModule = self._AbilityManager:GetAbility(WeaponConfig[weaponName].BasicAttack.Name)
        local SpecialAttack = self._AbilityManager:GetAbility(WeaponConfig[weaponName].BasicAttack.Name)

        self._BasicAttack = BasicAttackModule.new(WeaponConfig[weaponName].BasicAttack)
        self._SpecialAttack = SpecialAttack.new(WeaponConfig[weaponName].SpecialAttack)
    end
end

function CombatClass.UseBasicAttack(self: Object, context: UseBasicAttack_Context)
    if self._BasicAttack then
        self._BasicAttack:Activate({ Attacker = self._Character, Hits = context.Hits })
    end
end

function CombatClass.UseSpecialAttack(self: Object)
    
end

return CombatClass :: Module
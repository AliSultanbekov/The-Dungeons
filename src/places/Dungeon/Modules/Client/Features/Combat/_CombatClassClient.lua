--[=[
    @class CombatClassClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local AbilityManagerClient = require("./_AbilityManagerClient")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local CombatTypes = require("CombatTypes")
local WeaponConfig = require("WeaponConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatClassClient = {}
CombatClassClient.__index = CombatClassClient

-- [ Types ] --
type AbilityManagerClient = AbilityManagerClient.Object
type AbilityModule = CombatTypes.AbilityModule
type AbilityObject = CombatTypes.AbilityObject
export type ObjectData = {
    _Character: Model,
    _AbilityManagerClient: AbilityManagerClient,
    _BasicAttack: AbilityObject?,
    _SpecialAttack: AbilityObject?,
}
export type Object = ObjectData & {
    SetActiveWeapon: (self: Object, weaponName: string) -> (),
    UseBasicAttack: (self: Object) -> (),
    UseSpecialAttack: (self: Object) -> (),
}
export type Module = {
    __index: Module,
    new: (character: Model, abilityManagerClient: AbilityManagerClient) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatClassClient.new(character: Model, abilityManagerClient: AbilityManagerClient): Object
    local self = setmetatable({} :: any, CombatClassClient) :: Object
    
    self._Character = character
    self._AbilityManagerClient = abilityManagerClient
    self._BasicAttack = nil
    self._SpecialAttack = nil

    return self
end

function CombatClassClient.SetActiveWeapon(self: Object, weaponName: string?)
    if not weaponName then
        self._BasicAttack = nil
        self._SpecialAttack = nil
    else
        local BasicAttackModule = self._AbilityManagerClient:GetAbility(WeaponConfig[weaponName].BasicAttack.Name)
        local SpecialAttack = self._AbilityManagerClient:GetAbility(WeaponConfig[weaponName].BasicAttack.Name)

        self._BasicAttack = BasicAttackModule.new()
        self._SpecialAttack = SpecialAttack.new()
    end
end

function CombatClassClient.UseBasicAttack(self: Object)
    if self._BasicAttack then
        self._BasicAttack:Activate({ Attacker = self._Character })
    end
end

function CombatClassClient.UseSpecialAttack(self: Object)
    if self._SpecialAttack then
        self._SpecialAttack:Activate({ Attacker = self._Character })
    end
end

return CombatClassClient :: Module
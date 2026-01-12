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
type ClientAbilityData = CombatTypes.ClientAbilityData
type UseBasicAttack_Context = {
    Mode: Mode
}
type UseSpecialAttack_Context = {
    Mode: Mode
}
type Mode = CombatTypes.Mode
type AbilityManagerClient = AbilityManagerClient.Object
type AbilityModule = CombatTypes.ClientAbilityModule
type AbilityObject = CombatTypes.ClientAbilityObject
export type ObjectData = {
    _Character: Model,
    _AbilityManagerClient: AbilityManagerClient,
    _BasicAttack: AbilityObject?,
    _SpecialAttack: AbilityObject?,
}
export type Object = ObjectData & {
    SetActiveWeapon: (self: Object, weaponName: string) -> (),
    UseBasicAttack: (self: Object, Context: UseBasicAttack_Context) -> ClientAbilityData?,
    UseSpecialAttack: (self: Object, Context: UseSpecialAttack_Context) -> ClientAbilityData?,
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

        self._BasicAttack = BasicAttackModule.new(WeaponConfig[weaponName].BasicAttack)
        self._SpecialAttack = SpecialAttack.new(WeaponConfig[weaponName].SpecialAttack)
    end
end

function CombatClassClient.UseBasicAttack(self: Object, Context: UseBasicAttack_Context): ClientAbilityData?
    if self._BasicAttack then
        local AbilityData = self._BasicAttack:Activate({
            Mode = Context.Mode,
            Attacker = self._Character 
        })

        return AbilityData
    else
        return
    end
end

function CombatClassClient.UseSpecialAttack(self: Object, Context: UseBasicAttack_Context): ClientAbilityData?
    if self._SpecialAttack then
        local AbilityData = self._SpecialAttack:Activate({ 
            Mode = Context.Mode, 
            Attacker = self._Character 
        })

        return AbilityData
    else
        return
    end
end

return CombatClassClient :: Module
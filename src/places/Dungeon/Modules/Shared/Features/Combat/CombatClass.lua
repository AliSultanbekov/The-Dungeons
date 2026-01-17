--[=[
    @class CombatClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local CombatTypes = require("CombatTypes")
local AbilityManager = require("AbilityManager")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatClass = {}
CombatClass.__index = CombatClass

-- [ Types ] --
type AbilityObject = CombatTypes.ClientAbilityObject
type AbilityModule = CombatTypes.ClientAbilityModule

export type ObjectData = {
    _Character: Model,
    _AbilityManager: AbilityManager.Object,
    _Abilities: {
        [string]: AbilityObject
    }
}
export type Object = ObjectData & {
    UseAbility: (self: Object, abilityName: string, params: {[any]: any}?) -> (),
    EndAbility: (self: Object, abilityName: string, params: {[any]: any}?) -> (),
    HitAbility: (self: Object, abilityName: string, params: {[any]: any}?) -> (),
    AddAbility: (self: Object, abilityName: string, params: {[any]: any}?) -> (),
    RemoveAbility: (self: Object, abilityName: string, params: {[any]: any}?) -> (),
}
export type Module = {
    __index: Module,
    new: (character: Model, abilityManager: AbilityManager.Object) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatClass.new(character: Model, abilityManager: AbilityManager.Object): Object
    local self = setmetatable({} :: any, CombatClass) :: Object

    self._Character = character
    self._AbilityManager = abilityManager
    self._Abilities = {}

    return self
end

function CombatClass.UseAbility(self: Object, abilityName: string, params: {[any]: any}?)
    local Params: {[any]: any} = params or {}
    
    Params.Attacker = self._Character

    self._Abilities[abilityName]:Use(Params)
end

function CombatClass.EndAbility(self: Object, abilityName: string, params: {[any]: any}?)
    local Params: {[any]: any} = params or {}
    
    Params.Attacker = self._Character

    self._Abilities[abilityName]:End(Params)
end

function CombatClass.HitAbility(self: Object, abilityName: string, params: {[any]: any}?)
    local Params: {[any]: any} = params or {}

    Params.Attacker = self._Character

    self._Abilities[abilityName]:Hit(Params)
end

function CombatClass.AddAbility(self: Object, abilityName: string, params: {[any]: any}?)
    local Params: {[any]: any} = params or {}
    local AbilityModule: AbilityModule = self._AbilityManager:Get(abilityName)
    local AbiltyObject = AbilityModule.new(Params)

    self._Abilities[abilityName] = AbiltyObject
end

function CombatClass.RemoveAbility(self: Object, abilityName: string, params: {[any]: any}?)
    local _Params: {[any]: any} = params or {}
    self._Abilities[abilityName] = nil
end

return CombatClass :: Module
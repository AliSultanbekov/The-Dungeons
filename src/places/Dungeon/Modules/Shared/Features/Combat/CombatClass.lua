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
type CreatureService = {
    DamageCreature: (self: CreatureService, attacker: Model, attacked: Model, damageCount: number) -> boolean,
    GetCurrentAbility: (self: CreatureService, character: Model) -> Context?,
    GetPreviousAbility: (self: CreatureService, character: Model) -> Context?,
    IsStunned: (self: CreatureService, character: Model) -> boolean,
    TryUseAbility: (self: CreatureService, character: Model, abilityData: Context) -> boolean,
    TryEndAbility: (self: CreatureService, character: Model, abilityName: string?) -> boolean,
}
type AbilityObject = CombatTypes.AbilityObject
type AbilityModule = CombatTypes.AbilityModule
type Context = CombatTypes.Context

export type ObjectData = {
    _Character: Model,
    _AbilityManager: AbilityManager.Object,
    _CreatureService: CreatureService,
    _Abilities: {
        [string]: AbilityObject
    }
}
export type Object = typeof(setmetatable({} :: ObjectData, CombatClass))
export type Module = typeof(CombatClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatClass.new(character: Model, context: {AbilityManager: AbilityManager.Object, CreatureService: CreatureService}): Object
    local self = setmetatable({} :: any, CombatClass) :: Object

    self._Character = character
    self._AbilityManager = context.AbilityManager
    self._CreatureService = context.CreatureService
    self._Abilities = {}

    return self
end

function CombatClass.AddAbility(self: Object, abilityName: string, context: Context)
    local AbilityModule: AbilityModule = self._AbilityManager:Get(abilityName)

    context.CreatureService = self._CreatureService
    context.Attacker = self._Character

    local AbiltyObject = AbilityModule.new(context)

    self._Abilities[abilityName] = AbiltyObject
end

function CombatClass.RemoveAbility(self: Object, abilityName: string)
    self._Abilities[abilityName] = nil
end

function CombatClass.UseAbility(self: Object, abilityName: string, context: Context)
    if self._CreatureService:GetCurrentAbility(self._Character) then
        return
    end

    if self._CreatureService:IsStunned(self._Character) then
        return
    end

    self._Abilities[abilityName]:Use(context)
end

function CombatClass.EndAbility(self: Object, abilityName: string, context: Context)
    if not self._CreatureService:GetCurrentAbility(self._Character) then
        return
    end

    self._Abilities[abilityName]:End(context)
end

function CombatClass.HitAbility(self: Object, abilityName: string, context: Context)
    if not self._CreatureService:GetCurrentAbility(self._Character) then
        return
    end

    self._Abilities[abilityName]:Hit(context)
end

function CombatClass.UpdateAbilityState(self: Object, abilityName: string, context: Context)
    self._Abilities[abilityName]:UpdateState(context)
end

function CombatClass.GetAbilityState(self: Object, abilityName: string): Context
    return self._Abilities[abilityName]:GetState()
end

return CombatClass :: Module
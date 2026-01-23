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
type CombatEntityStateService = {
    GetPreviousAbility: (self: any, character: Model) -> { [string]: any }?,
    GetCurrentAbility: (self: any, character: Model) -> { [string]: any }?,
    SetCurrentAbility: (self: any, character: Model, data: { [string]: any }?) -> (),
    IsStunned: (self: any, character: Model) -> boolean,
    StartBlocking: (self: any, character: Model) -> boolean,
}
type AbilityObject = CombatTypes.AbilityObject
type AbilityModule = CombatTypes.AbilityModule
type Context = CombatTypes.Context

export type ObjectData = {
    _Character: Model,
    _AbilityManager: AbilityManager.Object,
    _CombatEntityStateService: CombatEntityStateService,
    _Abilities: {
        [string]: AbilityObject
    }
}
export type Object = typeof(setmetatable({} :: ObjectData, CombatClass))
export type Module = typeof(CombatClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatClass.new(character: Model, context: {AbilityManager: AbilityManager.Object, CombatEntityStateService: CombatEntityStateService}): Object
    local self = setmetatable({} :: any, CombatClass) :: Object

    self._Character = character
    self._AbilityManager = context.AbilityManager
    self._CombatEntityStateService = context.CombatEntityStateService
    self._Abilities = {}

    return self
end

function CombatClass.AddAbility(self: Object, abilityName: string, context: Context)
    local AbilityModule: AbilityModule = self._AbilityManager:Get(abilityName)

    context.CombatEntityStateService = self._CombatEntityStateService
    context.Attacker = self._Character

    local AbiltyObject = AbilityModule.new(context)

    self._Abilities[abilityName] = AbiltyObject
end

function CombatClass.RemoveAbility(self: Object, abilityName: string)
    self._Abilities[abilityName] = nil
end

function CombatClass.UseAbility(self: Object, abilityName: string, context: Context)
    if self._CombatEntityStateService:GetCurrentAbility(self._Character) then
        return
    end

    print(self._CombatEntityStateService:IsStunned(self._Character))

    if self._CombatEntityStateService:IsStunned(self._Character) then
        return
    end

    self._Abilities[abilityName]:Use(context)
end

function CombatClass.EndAbility(self: Object, abilityName: string, context: Context)
    if not self._CombatEntityStateService:GetCurrentAbility(self._Character) then
        return
    end

    self._Abilities[abilityName]:End(context)
end

function CombatClass.HitAbility(self: Object, abilityName: string, context: Context)
    if not self._CombatEntityStateService:GetCurrentAbility(self._Character) then
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
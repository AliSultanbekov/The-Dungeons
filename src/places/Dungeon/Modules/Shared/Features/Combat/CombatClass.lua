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
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatClass = {}
CombatClass.__index = CombatClass

-- [ Types ] --
type AbilityObject = CombatTypes.AbilityObject
type AbilityModule = CombatTypes.AbilityModule
type Context = CombatTypes.Context

type New_Context = {
    ServiceBag: ServiceBag.ServiceBag,
    AbilityManager: AbilityManager.Object,
    OnUse: (context: CombatTypes.Context) -> (),
    OnEnd: (context: CombatTypes.Context) -> (),
    OnHit: (context: CombatTypes.Context) -> (),
}
export type ObjectData = {
    _Character: Model,
    _ServiceBag: ServiceBag.ServiceBag,
    _AbilityManager: AbilityManager.Object,
    _CreatureService: any,
    _OnUse: (context: CombatTypes.Context) -> (),
    _OnEnd: (context: CombatTypes.Context) -> (),
    _OnHit: (context: CombatTypes.Context) -> (),
    _Abilities: {
        [string]: AbilityObject
    }
}
export type Object = typeof(setmetatable({} :: ObjectData, CombatClass))
export type Module = typeof(CombatClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatClass.new(character: Model, context: New_Context): Object
    local self = setmetatable({} :: any, CombatClass) :: Object
    
    self._Character = character

    self._ServiceBag = context.ServiceBag
    self._AbilityManager = context.AbilityManager

    self._OnUse = context.OnUse
    self._OnEnd = context.OnEnd
    self._OnHit = context.OnHit

    self._Abilities = {}

    return self
end

function CombatClass.AddAbility(self: Object, abilityName: string, context: Context)
    local AbilityModule: AbilityModule = self._AbilityManager:Get(abilityName)

    context.Attacker = self._Character
    context.ServiceBag = self._ServiceBag
    context.OnUse = self._OnUse
    context.OnEnd = self._OnEnd
    context.OnHit = self._OnHit

    local AbiltyObject = AbilityModule.new(context)

    self._Abilities[abilityName] = AbiltyObject
end

function CombatClass.RemoveAbility(self: Object, abilityName: string)
    self._Abilities[abilityName] = nil
end

function CombatClass.UseAbility(self: Object, abilityName: string, context: Context)
    self._Abilities[abilityName]:Use(context)
end

function CombatClass.EndAbility(self: Object, abilityName: string, context: Context)
    self._Abilities[abilityName]:End(context)
end

function CombatClass.HitAbility(self: Object, abilityName: string, context: Context)
    self._Abilities[abilityName]:Hit(context)
end

function CombatClass.UpdateAbilityState(self: Object, abilityName: string, context: Context)
    self._Abilities[abilityName]:UpdateState(context)
end

function CombatClass.GetAbilityState(self: Object, abilityName: string): Context
    return self._Abilities[abilityName]:GetState()
end

return CombatClass :: Module
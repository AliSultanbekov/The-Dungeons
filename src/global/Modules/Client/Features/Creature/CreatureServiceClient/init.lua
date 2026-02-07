--[=[
    @class CreatureServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local CreatureRegister = require("@self/_CreatureRegister")
local CreatureAbility = require("@self/_CreatureAbility")
local CreatureGeneric = require("@self/_CreatureGeneric")
local Types = require("./CreatureTypesClient")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Jecs = require("Jecs")
local EntityTypesClient = require("EntityTypesClient")
local AnimationClass = require("AnimationClass")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureServiceClient = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceClient: EntityServiceClient,
    _CreatureModules: {
        CreatureRegister: CreatureRegister.Module,
        CreatureAbility: CreatureAbility.Module,
        CreatureGeneric: CreatureGeneric.Module
    },
    PublicSignals: Types.PublicSignals
}

export type Module = typeof(CreatureServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureServiceClient.GetAnimationObject(self: Module, character: Model): AnimationClass.Object
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        error("[CreatureServiceClient] No Entity found for character " .. tostring(character))
    end

    return self._CreatureModules.CreatureGeneric:GetAnimationObject(Entity)
end

function CreatureServiceClient.IsAbilityOnCooldown(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:IsAbilityOnCooldown(Entity, abilityName)
end

function CreatureServiceClient.StartAbilityCooldown(self: Module, character: Model, abilityName: string, cooldownDuration: number?)
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    self._CreatureModules.CreatureAbility:StartAbilityCooldown(Entity, abilityName, cooldownDuration)
end

function CreatureServiceClient.IsAbilityActive(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:IsAbilityActive(Entity, abilityName)
end

function CreatureServiceClient.GetCurrentAbility(self: Module, character: Model, abilityName: string): (EntityTypesClient.BaseAbility | EntityTypesClient.ComboAbility)?
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    return self._CreatureModules.CreatureAbility:GetCurrentAbility(Entity, abilityName)
end

function CreatureServiceClient.GetPreviousAbility(self: Module, character: Model, abilityName: string): (EntityTypesClient.BaseAbility | EntityTypesClient.ComboAbility)?
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    return self._CreatureModules.CreatureAbility:GetPreviousAbility(Entity, abilityName)
end

function CreatureServiceClient.UseAbility(self: Module, character: Model, abilityData: EntityTypesClient.BaseAbility | EntityTypesClient.ComboAbility): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:UseAbility(Entity, abilityData)
end

function CreatureServiceClient.CancelAbility(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:CancelAbility(Entity, abilityName)
end

function CreatureServiceClient.EndAbility(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:EndAbility(Entity, abilityName)
end

function CreatureServiceClient.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CreatureModules.CreatureRegister:GetEntityFromCharacter(character)
end

function CreatureServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceClient = self._ServiceBag:GetService(require("EntityServiceClient"))
    self._CreatureModules = {
        CreatureRegister = CreatureRegister,
        CreatureAbility = CreatureAbility,
        CreatureGeneric = CreatureGeneric,
    }

    self.PublicSignals = {
        CreatureCreated = Signal.new(),
        CreatureDeleted = Signal.new(),
        AbilityExpired = Signal.new(),
    } :: any

    for _, creatureModule in pairs(self._CreatureModules) do
        creatureModule:Init({
            EntityServiceClient = self._EntityServiceClient,
            PublicSignals = self.PublicSignals
        })
    end
end

function CreatureServiceClient.Start(self: Module)
    for _, creatureModule in pairs(self._CreatureModules) do
        creatureModule:Start()
    end
end

return CreatureServiceClient :: Module

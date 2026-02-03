--[=[
    @class CreatureServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local CreatureRegister = require("@self/_CreatureRegister")
local CreatureAbility = require("@self/_CreatureAbility")
local CreatureGeneric = require("@self/_CreatureGeneric")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Jecs = require("Jecs")
local EntityTypesClient = require("EntityTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureServiceClient = {}

-- [ Types ] --
type CreatureModule = {
    Init: (self: CreatureModule, entityServiceClient: EntityServiceClient) -> (),
    Start: (self: CreatureModule) -> (),
}
type EntityServiceClient = typeof(require("EntityServiceClient"))
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceClient: EntityServiceClient,
    _CreatureModules: {
        CreatureRegister: CreatureRegister.Module,
        CreatureAbility: CreatureAbility.Module,
        CreatureGeneric: CreatureGeneric.Module
    }
}

export type Module = typeof(CreatureServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureServiceClient.IsAbilityOnCooldown(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:IsAbilityOnCooldown(Entity, abilityName)
end

function CreatureServiceClient.StartAbilityCooldown(self: Module, character: Model, abilityName: string)
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    self._CreatureModules.CreatureAbility:StartAbilityCooldown(Entity, abilityName)
end

function CreatureServiceClient.IsAbilityActive(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:IsAbilityActive(Entity, abilityName)
end

function CreatureServiceClient.GetCurrentAbility(self: Module, character: Model): EntityTypesClient.CurrentAbilityComponent?
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    return self._CreatureModules.CreatureAbility:GetCurrentAbility(Entity)
end

function CreatureServiceClient.GetPreviousAbility(self: Module, character: Model): EntityTypesClient.PreviousAbilityComponent?
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    return self._CreatureModules.CreatureAbility:GetPreviousAbility(Entity)
end

function CreatureServiceClient.UseAbility(self: Module, character: Model, abilityData: EntityTypesClient.CurrentAbilityComponent): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:UseAbility(Entity, abilityData)
end

function CreatureServiceClient.CancelAbility(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:CancelAbility(Entity, abilityName)
end

function CreatureServiceClient.EndAbility(self: Module, character: Model, abilityName: string?): boolean
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

    for _, creatureModule in pairs(self._CreatureModules) do
        creatureModule:Init(self._EntityServiceClient)
    end
end

function CreatureServiceClient.Start(self: Module)
    for _, creatureModule in pairs(self._CreatureModules) do
        creatureModule:Start()
    end
end

return CreatureServiceClient :: Module

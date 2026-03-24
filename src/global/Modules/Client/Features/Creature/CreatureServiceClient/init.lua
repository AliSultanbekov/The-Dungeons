--[=[
    @class CreatureServiceClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local CreatureRegister = require("@self/_CreatureRegister")
local CreatureAbility = require("@self/_CreatureAbility")
local CreatureGeneric = require("@self/_CreatureGeneric")
local CreatureAnimator = require("@self/_CreatureAnimator")
local CreatureVelocity = require("@self/_CreatureVelocity")
local CreatureHealth = require("@self/_CreatureHealth")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Jecs = require("Jecs")
local EntityTypesClient = require("EntityTypesClient")
local CreatureTypesClient = require("CreatureTypesClient")
local AnimatorClass = require("AnimatorClass")
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
        CreatureGeneric: CreatureGeneric.Module,
        CreatureAnimator: CreatureAnimator.Module,
        CreatureVelocity: CreatureVelocity.Module,
        CreatureHealth: CreatureHealth.Module,
    },
    PublicSignals: CreatureTypesClient.PublicSignals
}

export type Module = typeof(CreatureServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureServiceClient.ObservePlayerCreature(self: Module, player: Player, cb: (character: Model, entity: Jecs.Entity) -> ())
    local World = self._EntityServiceClient:GetWorld()
    local Tags = self._EntityServiceClient:GetTags()

    for character, entity in self._CreatureModules.CreatureRegister:GetAllCreatures() do
        if not World:has(entity, Tags.Player) then
            continue
        end

        local Player = Players:GetPlayerFromCharacter(character)

        if not Player then
            continue
        end

        if player == Player then
            cb(character, entity)
        end
    end

    return self.PublicSignals.CreatureCreated:Connect(function(packet: CreatureTypesClient.CreatureCreatedSignalPacket)
        if not World:has(packet.Entity, Tags.Player) then
            return
        end

        local Player = Players:GetPlayerFromCharacter(packet.Character)

        if not Player then
            return
        end

        if player == Player then
            cb(packet.Character, packet.Entity)
        end
    end)
end

function CreatureServiceClient.ObserveCreatures(self: Module, cb: (character: Model, entity: Jecs.Entity) -> ())
    for character, entity in self._CreatureModules.CreatureRegister:GetAllCreatures() do
        cb(character, entity)
    end

    return self.PublicSignals.CreatureCreated:Connect(function(packet: CreatureTypesClient.CreatureCreatedSignalPacket)
        cb(packet.Character, packet.Entity)
    end)
end

function CreatureServiceClient.ObserveCreatureHealth(self: Module, character: Model, cb: (newHealth: number) -> ())
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        error("Entity not found for given character")
    end

    return self._CreatureModules.CreatureHealth:ObserveCreatureHealth(Entity, cb)
end

function CreatureServiceClient.GetCreatureHealth(self: Module, character: Model): number
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        error("Entity not found for given character")
    end

    return self._CreatureModules.CreatureHealth:GetCreatureHealth(Entity)
end

function CreatureServiceClient.ApplyLinearVelocityOnCreature(self: Module, character: Model, componentConfig: CreatureTypesClient.ComponentConfig, velocityConfig: CreatureTypesClient.LinearVelocityConfig)
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return 
    end

    self._CreatureModules.CreatureVelocity:ApplyLinearVelocityOnCreature(Entity, componentConfig, velocityConfig)
end

function CreatureServiceClient.GetAnimationObject(self: Module, character: Model): AnimatorClass.Object
    return self._CreatureModules.CreatureAnimator:GetAnimationObject(character)
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
        CreatureAnimator = CreatureAnimator,
        CreatureVelocity = CreatureVelocity,
        CreatureHealth = CreatureHealth,
    }

    self.PublicSignals = {
        CreatureCreated = Signal.new(),
        CreatureDeleted = Signal.new(),
        AbilityExpired = Signal.new(),
    } :: any

    for _, creatureModule: CreatureTypesClient.CreatureModule in pairs(self._CreatureModules) do
        creatureModule:Init({
            EntityServiceClient = self._EntityServiceClient,
            Signals = self.PublicSignals

        })
    end
end

function CreatureServiceClient.Start(self: Module)
    for _, creatureModule in pairs(self._CreatureModules) do
        creatureModule:Start()
    end
end

return CreatureServiceClient :: Module

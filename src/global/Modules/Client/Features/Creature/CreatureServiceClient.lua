--[=[
    @class CreatureServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local EntityTypesClient = require("EntityTypesClient")
local Jecs = require("Jecs")
local CreatureUtil = require("CreatureUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceClient: typeof(require("EntityServiceClient")),
    _CharacterToEntity: {
        [Model]: Jecs.Entity
    }
}

export type Module = typeof(CreatureServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureServiceClient.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CharacterToEntity[character]
end

function CreatureServiceClient.DamageCreature(self: Module, attacker: Model, attacked: Model): string?
    local AttackerEntity = self:GetEntityFromCharacter(attacker)
    local AttackedEntity = self:GetEntityFromCharacter(attacked)

    local World = self._EntityServiceClient:GetWorld()
    local Tags = self._EntityServiceClient:GetTags()
    local Components = self._EntityServiceClient:GetComponents()

    local CanDamage = CreatureUtil:CanDamage({
        AttackerEntity = AttackerEntity,
        AttackedEntity = AttackedEntity,
        World = World,
        Tags = Tags,
        Components = Components
    })

    if not CanDamage then
        return
    end

    local HitInfo = CreatureUtil:GetHitInfo({
        AttackerEntity = AttackerEntity,
        AttackedEntity = AttackedEntity,
        World = World,
        Components = Components
    })

    if not HitInfo then
        return
    end

    return HitInfo
end

function CreatureServiceClient.IsAbilityOnCooldown(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    return CreatureUtil:IsAbilityOnCooldown({
        Entity = Entity,
        World = World,
        Components = Components,
        AbilityName = abilityName
    })
end

function CreatureServiceClient.StartAbilityCooldown(self: Module, character: Model, abilityName: string)
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    CreatureUtil:StartAbilityCooldown({
        Entity = Entity,
        World = World,
        Components = Components,
        AbilityName = abilityName
    })
end

function CreatureServiceClient.IsAbilityActive(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    return CreatureUtil:IsAbilityActive({
        Entity = Entity,
        World = World,
        Components = Components,
        AbilityName = abilityName
    })
end

function CreatureServiceClient.GetCurrentAbility(self: Module, character: Model): EntityTypesClient.CurrentAbilityComponent?
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()
    
    return CreatureUtil:GetCurrentAbility({
        Entity = Entity,
        World = World,
        Components = Components
    }) :: EntityTypesClient.CurrentAbilityComponent
end

function CreatureServiceClient.GetPreviousAbility(self: Module, character: Model): EntityTypesClient.PreviousAbilityComponent?
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()
    
    return CreatureUtil:GetPreviousAbility({
        Entity = Entity,
        World = World,
        Components = Components
    }) :: EntityTypesClient.PreviousAbilityComponent
end

function CreatureServiceClient.TryUseAbility(self: Module, character: Model, abilityData: EntityTypesClient.CurrentAbilityComponent): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    if not CreatureUtil:CanUseAbility({
        Entity = Entity,
        World = World,
        Components = Components,
        AbilityData = abilityData
    }) then
        return false
    end

    local CurrentAbility = World:get(Entity, Components.CurrentAbility)

    if CurrentAbility then
        local CanCancelOrEnd = CreatureUtil:CanCancelOrEndAbility({
            Entity = Entity,
            World = World,
            Components = Components,
            AbilityData = abilityData
        })

        if not CanCancelOrEnd then
            return false
        end

        if CanCancelOrEnd == "End" then
            World:set(Entity, Components.PreviousAbility, table.clone(CurrentAbility))
        end

        World:remove(Entity, Components.CurrentAbility)

        if CurrentAbility.AbilityName == "Block" then
            World:remove(Entity, Components.Blocking)
        end
    end

    World:set(Entity, Components.CurrentAbility, abilityData)

    if abilityData.AbilityName == "Block" then
        World:set(Entity, Components.Blocking, true)
    end

    return true
end

function CreatureServiceClient.TryEndAbility(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CanEndAbility = CreatureUtil:CanEndAbility({
        Entity = Entity,
        World = World,
        Components = Components,
        AbilityName = abilityName
    })

    if not CanEndAbility then
        return false
    end

    local CurrentAbility = World:get(Entity, Components.CurrentAbility) :: EntityTypesClient.CurrentAbilityComponent

    if not CurrentAbility then
        return false
    end

    World:set(Entity, Components.PreviousAbility, table.clone(CurrentAbility))
    World:remove(Entity, Components.CurrentAbility)

    if CurrentAbility.AbilityName == "Block" then
        World:remove(Entity, Components.Blocking)
    end

    return true
end

function CreatureServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceClient = self._ServiceBag:GetService(require("EntityServiceClient"))
    self._CharacterToEntity = {}
end

function CreatureServiceClient.Start(self: Module)
    self._EntityServiceClient.PublicSignals.EntityCreated:Connect(function(packet: EntityTypesClient.EntityCreatedSignalPacket)
        local CharacterData = packet.Components.Character

        if not CharacterData then
            return
        end

        local Character = CharacterData.Character

        if not Character then
            return
        end

        self._CharacterToEntity[Character] = packet.Entity
    end)

    self._EntityServiceClient.PublicSignals.EntityDeleted:Connect(function(packet: EntityTypesClient.EntityDeletedSignalPacket)
        local CharacterData = packet.Components.Character

        if not CharacterData then
            return
        end

        self._CharacterToEntity[CharacterData.Character] = nil
    end)
end

return CreatureServiceClient :: Module

--[=[
    @class CreatureServiceServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local EntityTypesServer = require("EntityTypesServer")
local Maid = require("Maid")
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceServer: typeof(require("EntityServiceServer")),
    _EntityReplicationServiceServer: typeof(require("EntityReplicationServiceServer")),
    _PlayerCharacterManager: typeof(require("PlayerCharacterManager")),
    _CharacterToEntity: {
        [Model]: Jecs.Entity
    }
}

export type Module = typeof(CreatureServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureServiceServer.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CharacterToEntity[character]
end

function CreatureServiceServer.DamageCreature(self: Module, attacker: Model, attacked: Model, damageCount: number): boolean
    local AttackerEntity = self:GetEntityFromCharacter(attacker)
    local AttackedEntity = self:GetEntityFromCharacter(attacked)

    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()
    local Components = self._EntityServiceServer:GetComponents()

    if not World:has(AttackerEntity, Tags.Alive, Components.Health) then
        return false
    end

    if not World:has(AttackedEntity, Tags.Alive, Components.Health) then
        return false
    end

    local AttackedHealth = World:get(AttackedEntity, Components.Health) :: EntityTypesServer.HealthComponent

    if AttackedHealth <= 0 then
        return false
    end

    if World:get(AttackerEntity, Components.Stunned) then
        return false
    end

    World:set(AttackedEntity, Components.Health, math.max(0, AttackedHealth - damageCount))

    return true
end

function CreatureServiceServer.GetCurrentAbility(self: Module, character: Model): EntityTypesServer.CurrentAbilityComponent?
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    if not World:has(Entity, Components.CurrentAbility) then
        return nil
    end

    return World:get(Entity, Components.CurrentAbility) :: EntityTypesServer.CurrentAbilityComponent
end

function CreatureServiceServer.GetPreviousAbility(self: Module, character: Model): EntityTypesServer.PreviousAbilityComponent?
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    if not World:has(Entity, Components.PreviousAbility) then
        return nil
    end

    return World:get(Entity, Components.PreviousAbility) :: EntityTypesServer.PreviousAbilityComponent
end

function CreatureServiceServer.IsStunned(self: Module, character: Model): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    return World:has(Entity, Components.Stunned)
end

function CreatureServiceServer.TryUseAbility(self: Module, character: Model, abilityData: EntityTypesServer.CurrentAbilityComponent): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    if World:has(Entity, Components.Stunned) then
        return false
    end

    if World:has(Entity, Components.CurrentAbility) then
        return false
    end

    local Ether = World:get(Entity, Components.Ether) :: EntityTypesServer.EtherComponent?

    if not Ether or Ether <= 0 then
        return false
    end

    World:set(Entity, Components.CurrentAbility, abilityData)

    if abilityData.AbilityName == "Block" then
        World:add(Entity, Components.Blocking)
    end

    return true
end

function CreatureServiceServer.TryEndAbility(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    local CurrentAbility = World:get(Entity, Components.CurrentAbility) :: EntityTypesServer.CurrentAbilityComponent?

    if not CurrentAbility then
        return false
    end

    if abilityName and CurrentAbility.AbilityName ~= abilityName then
        return false
    end

    World:set(Entity, Components.PreviousAbility, table.clone(CurrentAbility))
    World:remove(Entity, Components.CurrentAbility)

    if CurrentAbility.AbilityName == "Block" then
        World:remove(Entity, Components.Blocking)
    end

    return true
end

function CreatureServiceServer.RegisterNPC(self: Module, character: Model)
    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Entity = self._EntityServiceServer:CreateEntity({
        Tags = {
            "Alive",
            "NPC"
        },
        Components = {
            Name = character.Name,
            Health = 100,
            Ether = 100,
            Character = {
                Character = character,
                Humanoid = Humanoid,
            }
        },
        Replicated = true
    })

    self._CharacterToEntity[character] = Entity

    character.Destroying:Once(function()  
        self._EntityServiceServer:DeleteEntity({ Entity = Entity, Replicated = true })
        self._CharacterToEntity[character] = nil
    end)
end

function CreatureServiceServer.RegisterPlayer(self: Module, character: Model)
    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Entity = self._EntityServiceServer:CreateEntity({
        Tags = {
            "Alive",
            "Player"
        },
        Components = {
            Name = character.Name,
            Health = 100,
            Ether = 100,
            Character = {
                Character = character,
                Humanoid = Humanoid,
            }
        },
        Replicated = true
    })

    self._CharacterToEntity[character] = Entity

    character.Destroying:Once(function()  
        self._EntityServiceServer:DeleteEntity({ Entity = Entity, Replicated = true })
        self._CharacterToEntity[character] = nil
    end)
end

function CreatureServiceServer.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    self:RegisterPlayer(character)
end

function CreatureServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceServer = self._ServiceBag:GetService(require("EntityServiceServer"))
    self._EntityReplicationServiceServer = self._ServiceBag:GetService(require("EntityReplicationServiceServer"))
    self._PlayerCharacterManager = self._ServiceBag:GetService(require("PlayerCharacterManager"))
    self._CharacterToEntity = {}
end

function CreatureServiceServer.Start(self: Module)
    self._PlayerCharacterManager:RegisterModule(self)
end

return CreatureServiceServer :: Module
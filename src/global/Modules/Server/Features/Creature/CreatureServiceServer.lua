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
local CreatureUtil = require("CreatureUtil")

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

function CreatureServiceServer.DamageCreature(self: Module, attacker: Model, attacked: Model, damageCount: number): string?
    local AttackerEntity = self:GetEntityFromCharacter(attacker)
    local AttackedEntity = self:GetEntityFromCharacter(attacked)

    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()
    local Components = self._EntityServiceServer:GetComponents()

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

    local AttackedHealth = World:get(AttackedEntity, Components.Health)

    if not AttackedHealth then
        return
    end

    if HitInfo == "Hit" then
        World:set(AttackedEntity, Components.Health, math.max(0, AttackedHealth - damageCount))
    end

    return HitInfo
end

function CreatureServiceServer.IsAbilityActive(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    return CreatureUtil:IsAbilityActive({
        Entity = Entity,
        World = World,
        Components = Components,
        AbilityName = abilityName
    })
end

function CreatureServiceServer.GetCurrentAbility(self: Module, character: Model): EntityTypesServer.CurrentAbilityComponent?
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()
    
    return CreatureUtil:GetCurrentAbility({
        Entity = Entity,
        World = World,
        Components = Components
    }) :: EntityTypesServer.CurrentAbilityComponent
end

function CreatureServiceServer.GetPreviousAbility(self: Module, character: Model): EntityTypesServer.PreviousAbilityComponent?
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()
    
    return CreatureUtil:GetPreviousAbility({
        Entity = Entity,
        World = World,
        Components = Components
    }) :: EntityTypesServer.PreviousAbilityComponent
end

function CreatureServiceServer.TryUseAbility(self: Module, character: Model, abilityData: EntityTypesServer.CurrentAbilityComponent): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    local CanUseAbility = CreatureUtil:CanUseAbility({
        Entity = Entity,
        World = World,
        Components = Components,
        AbilityData = abilityData
    })

    if not CanUseAbility then
        return false
    end

    World:set(Entity, Components.CurrentAbility, abilityData)

    if abilityData.AbilityName == "Block" then
        World:set(Entity, Components.Blocking, true)
    end

    return true
end

function CreatureServiceServer.TryEndAbility(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    local CanEndAbility = CreatureUtil:CanEndAbility({
        Entity = Entity,
        World = World,
        Components = Components,
        AbilityName = abilityName
    })

    if not CanEndAbility then
        return false
    end

    local CurrentAbility = World:get(Entity, Components.CurrentAbility) :: EntityTypesServer.CurrentAbilityComponent

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
            Health = 1000,
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
            Health = 1000,
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
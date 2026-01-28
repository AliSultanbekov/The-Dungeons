--[=[
    @class CreatureServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local GetEntityFromCharacter = require("GetEntityFromCharacter")
local EntityTypesClient = require("EntityTypesClient")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceClient: typeof(require("EntityServiceClient")),
    _PlayerCharacterManager: typeof(require("PlayerCharacterManager"))
}

export type Module = typeof(CreatureServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureServiceClient.GetCurrentAbility(self: Module, character: Model): EntityTypesClient.CurrentAbilityComponent?
    local Entity = GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    if not World:has(Entity, Components.CurrentAbility) then
        return nil
    end

    return World:get(Entity, Components.CurrentAbility) :: EntityTypesClient.CurrentAbilityComponent
end

function CreatureServiceClient.GetPreviousAbility(self: Module, character: Model): EntityTypesClient.PreviousAbilityComponent?
    local Entity = GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    if not World:has(Entity, Components.PreviousAbility) then
        return nil
    end

    return World:get(Entity, Components.PreviousAbility) :: EntityTypesClient.PreviousAbilityComponent
end

function CreatureServiceClient.IsStunned(self: Module, character: Model): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    return World:has(Entity, Components.Stunned)
end

function CreatureServiceClient.DamageCreature(self: Module, attacker: Model, attacked: Model, damageCount: number): boolean
    local AttackerEntity = GetEntityFromCharacter(attacker)
    local AttackedEntity = GetEntityFromCharacter(attacked)

    local World = self._EntityServiceClient:GetWorld()
    local Tags = self._EntityServiceClient:GetTags()
    local Components = self._EntityServiceClient:GetComponents()

    if not World:has(AttackerEntity, Tags.Alive, Components.Health) then
        return false
    end

    if not World:has(AttackedEntity, Tags.Alive, Components.Health) then
        return false
    end

    local AttackedHealth = World:get(AttackedEntity, Components.Health) :: EntityTypesClient.HealthComponent

    if AttackedHealth <= 0 then
        return false
    end

    if World:has(AttackerEntity, Components.Stunned) then
        return false
    end

    World:set(AttackedEntity, Components.Health, math.max(0, AttackedHealth - damageCount))

    return true
end

function CreatureServiceClient.TryUseAbility(self: Module, character: Model, abilityData: EntityTypesClient.CurrentAbilityComponent): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    if World:has(Entity, Components.Stunned) then
        return false
    end

    if World:has(Entity, Components.CurrentAbility) then
        return false
    end

    local Ether = World:get(Entity, Components.Ether) :: EntityTypesClient.EtherComponent?

    if not Ether or Ether <= 0 then
        return false
    end

    World:set(Entity, Components.CurrentAbility, abilityData)

    if abilityData.AbilityName == "Block" then
        World:add(Entity, Components.Blocking)
    end

    return true
end

function CreatureServiceClient.TryEndAbility(self: Module, character: Model, abilityName: string?): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CurrentAbility = World:get(Entity, Components.CurrentAbility) :: EntityTypesClient.CurrentAbilityComponent?

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

function CreatureServiceClient.CreatePlayer(self: Module, character: Model)
    local World = self._EntityServiceClient:GetWorld()
    local Tags = self._EntityServiceClient:GetTags()
    local Components = self._EntityServiceClient:GetComponents()

    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Entity = World:entity()
    World:add(Entity, Tags.Alive)
    World:add(Entity, Tags.Player)
    World:set(Entity, Components.Health, 100)
    World:set(Entity, Components.Ether, 100)
    World:set(Entity, Components.Character, {
        Character = character,
        Humanoid = Humanoid,
    })

    character:SetAttribute("Entity", Entity)
    
    character.Destroying:Once(function()
        World:delete(Entity)
    end)
end

function CreatureServiceClient.CreateNPC(self: Module, character: Model)
    local World = self._EntityServiceClient:GetWorld()
    local Tags = self._EntityServiceClient:GetTags()
    local Components = self._EntityServiceClient:GetComponents()

    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Entity = World:entity()
    World:add(Entity, Tags.Alive)
    World:add(Entity, Tags.NPC)
    World:set(Entity, Components.Health, 100)
    World:set(Entity, Components.Ether, 100)
    World:set(Entity, Components.Character, {
        Character = character,
        Humanoid = Humanoid,
    })

    character:SetAttribute("Entity", Entity)

    character.Destroying:Once(function()
        World:delete(Entity)
    end)
end

function CreatureServiceClient.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    self:CreatePlayer(character)
end

function CreatureServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceClient = self._ServiceBag:GetService(require("EntityServiceClient"))
    self._PlayerCharacterManager = self._ServiceBag:GetService(require("PlayerCharacterManager"))
end

function CreatureServiceClient.Start(self: Module)
    self._PlayerCharacterManager:RegisterModule(self)
end

return CreatureServiceClient :: Module

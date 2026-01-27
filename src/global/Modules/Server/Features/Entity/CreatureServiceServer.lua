--[=[
    @class CreatureServiceServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Brio = require("Brio")
local GetEntityFromCharacter = require("GetEntityFromCharacter")
local EntityTypesServer = require("EntityTypesServer")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceServer: typeof(require("EntityServiceServer"))
}

export type Module = typeof(CreatureServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureServiceServer.CreateNPC(self: Module, character: Model)
    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()
    local Components = self._EntityServiceServer:GetComponents()

    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local BrioObject = Brio.new(character)
    local MaidObject = BrioObject:ToMaid()

    local Entity = World:entity()
    World:add(Entity, Tags.Alive)
    World:add(Entity, Tags.NPC)
    World:set(Entity, Components.Health, 100)
    World:set(Entity, Components.Ether, 100)
    World:set(Entity, Components.Character, {
        Character = character,
        Humanoid = Humanoid
    })

    MaidObject:Add(function()
        World:delete(Entity)
    end)
end

function CreatureServiceServer.CreatePlayer(self: Module, character: Model)
    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()
    local Components = self._EntityServiceServer:GetComponents()

    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local BrioObject = Brio.new(character)
    local MaidObject = BrioObject:ToMaid()

    local Entity = World:entity()
    World:add(Entity, Tags.Alive)
    World:add(Entity, Tags.Player)
    World:set(Entity, Components.Health, 100)
    World:set(Entity, Components.Ether, 100)
    World:set(Entity, Components.Character, {
        Character = character,
        Humanoid = Humanoid
    })
    
    MaidObject:Add(function()
        World:delete(Entity)
    end)
end

function CreatureServiceServer.DamageCreature(self: Module, attacker: Model, attacked: Model, damageCount: number): boolean
    local AttackerEntity = GetEntityFromCharacter(attacker)
    local AttackedEntity = GetEntityFromCharacter(attacked)

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
    local Entity = GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    if not World:has(Entity, Components.CurrentAbility) then
        return nil
    end

    return World:get(Entity, Components.CurrentAbility) :: EntityTypesServer.CurrentAbilityComponent
end

function CreatureServiceServer.GetPreviousAbility(self: Module, character: Model): EntityTypesServer.PreviousAbilityComponent?
    local Entity = GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    if not World:has(Entity, Components.PreviousAbility) then
        return nil
    end

    return World:get(Entity, Components.PreviousAbility) :: EntityTypesServer.PreviousAbilityComponent
end

function CreatureServiceServer.IsStunned(self: Module, character: Model): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._EntityServiceServer:GetWorld()
    local Components = self._EntityServiceServer:GetComponents()

    return World:has(Entity, Components.Stunned)
end

function CreatureServiceServer.TryUseAbility(self: Module, character: Model, abilityData: EntityTypesServer.CurrentAbilityComponent): boolean
    local Entity = GetEntityFromCharacter(character)
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
    local Entity = GetEntityFromCharacter(character)
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

function CreatureServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceServer = self._ServiceBag:GetService(require("EntityServiceServer"))
end

function CreatureServiceServer.Start(self: Module)
    
end

return CreatureServiceServer :: Module
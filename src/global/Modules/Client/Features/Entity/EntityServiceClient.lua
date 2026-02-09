--[=[
    @class EntityServiceClient
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local rbxrequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Jecs = require("Jecs")
local EntityTypesClient = require("EntityTypesClient")
local Jabby = require("Jabby")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --
local SystemsFolder = script.Parent.Systems

-- [ Module Table ] --
local EntityServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _World: Jecs.World,
    _Tags: EntityTypesClient.Tags,
    _Components: EntityTypesClient.Components,
    _Systems: { EntityTypesClient.SystemModule },
    PublicSignals: EntityTypesClient.PublicSignals
}

export type Module = typeof(EntityServiceClient) & ModuleData

-- [ Private Functions ] --
function EntityServiceClient._GatherAllSystems(self: Module): { EntityTypesClient.SystemModule }
    local Systems = {}

    for _, instance in SystemsFolder:GetDescendants() do
        if not instance:IsA("ModuleScript") then
            continue
        end

        if not instance.Name:lower():find("system") then
            continue
        end

        Systems[instance.Name] = rbxrequire(instance)
    end

    return Systems
end

-- [ Public Functions ] --
function EntityServiceClient.GetComponents(self: Module): EntityTypesClient.Components
    return self._Components
end

function EntityServiceClient.GetTags(self: Module): EntityTypesClient.Tags
    return self._Tags
end

function EntityServiceClient.GetWorld(self: Module): Jecs.World
    return self._World
end

function EntityServiceClient.CreateEntity(self: Module, entityData: EntityTypesClient.EntityCreationData): Jecs.Entity
    local World = self._World
    local Entity = World:entity()

    for tagName in entityData.Tags do
        World:add(Entity, self._Tags[tagName])
    end

    for componentName, data in entityData.Components do
        World:set(Entity, self._Components[componentName], data)
    end

    self.PublicSignals.EntityCreated:Fire({
        Entity = Entity,
        Tags = entityData.Tags,
        Components = entityData.Components,
    })

    return Entity
end

function EntityServiceClient.DeleteEntity(self: Module, entityData: EntityTypesClient.EntityDeletionData)
    local Entity = entityData.Entity
    local World = self._World

    local Tags = {}
    local Components = {}

    for tagName, tag in pairs(self._Components) do
        if World:has(Entity, tag) then
            Tags[tagName] = true
        end
    end

    for componentName, component in pairs(self._Components) do
        if World:has(Entity, component) then
            Components[componentName] = World:get(Entity, component)
        end
    end

    self.PublicSignals.EntityDeleted:Fire({
        Entity = Entity,
        Tags = Tags,
        Components = Components,
    })

    World:delete(Entity)
end

function EntityServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._Tags = {
        Creature = Jecs.tag(),
        Player = Jecs.tag(),
        NPC = Jecs.tag(),
    }
    self._World = Jecs.World.new()
    self._Components = {
        -- Shared
        Name = self._World:component(),
        Stats = self._World:component(),
        Character = self._World:component(),
        Health = self._World:component(),
        Ether = self._World:component(),
            -- Combat
        AbilityCooldowns = self._World:component(),
        CurrentAbilities = self._World:component(),
        PreviousAbilities = self._World:component(),

        Blocking = self._World:component(),
        Parrying = self._World:component(),
        Dodging = self._World:component(),

        ParryStunned = self._World:component(),
        Stunned = self._World:component(),

        InCombat = self._World:component(),

        AnimationObject = self._World:component(),
        Velocity = self._World:component()
    }

    -- Tag Names
    self._World:set(self._Tags.Creature, Jecs.Name, "Creature")
    self._World:set(self._Tags.Player, Jecs.Name, "Player")
    self._World:set(self._Tags.NPC, Jecs.Name, "NPC")

    -- Component Names
    self._World:set(self._Components.Name, Jecs.Name, "Name")
    self._World:set(self._Components.Stats, Jecs.Name, "Stats")
    self._World:set(self._Components.Character, Jecs.Name, "Character")
    self._World:set(self._Components.Health, Jecs.Name, "Health")
    self._World:set(self._Components.Ether, Jecs.Name, "Ether")
    self._World:set(self._Components.AbilityCooldowns, Jecs.Name, "AbilityCooldowns")
    self._World:set(self._Components.InCombat, Jecs.Name, "InCombat")
    self._World:set(self._Components.Blocking, Jecs.Name, "Blocking")
    self._World:set(self._Components.Parrying, Jecs.Name, "Parrying")
    self._World:set(self._Components.Dodging, Jecs.Name, "Dodging")
    self._World:set(self._Components.ParryStunned, Jecs.Name, "ParryStunned")
    self._World:set(self._Components.Stunned, Jecs.Name, "Stunned")
    self._World:set(self._Components.CurrentAbilities, Jecs.Name, "CurrentAbility")
    self._World:set(self._Components.PreviousAbilities, Jecs.Name, "PreviousAbility")
    self._World:set(self._Components.AnimationObject, Jecs.Name, "AnimationObject")
    self._World:set(self._Components.Velocity, Jecs.Name, "Velocity")

    self._Systems = self:_GatherAllSystems()

    self.PublicSignals = {
        EntityCreated = Signal.new(),
        EntityDeleted = Signal.new(),
        AbilityExpired = Signal.new(),
    } :: any
end

function EntityServiceClient.Start(self: Module)
    RunService.RenderStepped:Connect(function(dt: number)
        for _, systemModule in self._Systems do
            systemModule:Update({
                World = self._World,
                Tags = self._Tags,
                Components = self._Components,
                PublicSignals = self.PublicSignals,
                Dt = dt,
            })
        end
    end)

    Jabby.register({
        applet = Jabby.applets.world,
        name = "world",
        configuration = {
            world = self._World
        }
    })
end

return EntityServiceClient :: Module

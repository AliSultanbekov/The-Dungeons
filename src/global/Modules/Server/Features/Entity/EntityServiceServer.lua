--[=[
    @class EntityServiceServer
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
local EntityTypesServer = require("EntityTypesServer")
local Jabby = require("Jabby")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EntityServiceServer = {}

-- [ Types ] --
type EntityCreationData = {
    Tags: { string },
    Components: { [string]: any },
    Replicated: boolean,
}
type EntityDeletionData = {
    Entity: Jecs.Entity,
    Replicated: boolean
}
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _World: Jecs.World,
    _Tags: EntityTypesServer.Tags,
    _Components: EntityTypesServer.Components,
    _Systems: { EntityTypesServer.SystemModule },
    ReplicationSignals: {
        EntityCreated: Signal.Signal<EntityTypesServer.EntityCreatedSignalPacket>,
        EntityDeleted: Signal.Signal<EntityTypesServer.EntityDeletedSignalPacket>,
    }
}

export type Module = typeof(EntityServiceServer) & ModuleData

-- [ Private Functions ] --
function EntityServiceServer._GatherAllSystems(self: Module): { EntityTypesServer.SystemModule }
    local SystemsFolder = script.Parent:FindFirstChild("Systems")

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
function EntityServiceServer.CreateEntity(self: Module, EntityData: EntityCreationData): Jecs.Entity
    local World = self._World
    local Entity = World:entity()

    for _, tagName in EntityData.Tags do
        World:add(Entity, self._Tags[tagName])
    end

    for componentName, data in EntityData.Components do
        World:set(Entity, self._Components[componentName], data)
    end

    if EntityData.Replicated then
        self.ReplicationSignals.EntityCreated:Fire({
            Entity = Entity,
            Tags = EntityData.Tags,
            Components = EntityData.Components,
        })
    end

    return Entity
end

function EntityServiceServer.DeleteEntity(self: Module, EntityData: EntityDeletionData)
    local Entity = EntityData.Entity
    local World = self._World

    World:delete(Entity)

    if EntityData.Replicated then
        self.ReplicationSignals.EntityDeleted:Fire({
            Entity = Entity
        })
    end
end

function EntityServiceServer.GetComponents(self: Module): EntityTypesServer.Components
    return self._Components
end

function EntityServiceServer.GetTags(self: Module): EntityTypesServer.Tags
    return self._Tags
end

function EntityServiceServer.GetWorld(self: Module): Jecs.World
    return self._World
end

function EntityServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._Tags = {
        Alive = Jecs.tag(),
        Player = Jecs.tag(),
        NPC = Jecs.tag(),
        Replicated = Jecs.tag(),
    }
    self._World = Jecs.World.new()
    self._Components = {
        Name = self._World:component(),
        Stats = self._World:component(),
        Character = self._World:component(),
        Prefab = self._World:component(),

        Health = self._World:component(),
        Ether = self._World:component(),

        InCombat = self._World:component(),

        Blocking = self._World:component(),
        Dodging = self._World:component(),
        Stunned = self._World:component(),
        CurrentAbility = self._World:component(),
        PreviousAbility = self._World:component(),

        HealthBuff = self._World:component(),
        DamageBuff = self._World:component(),
        SpeedBuff = self._World:component(),
        MitigationBuff = self._World:component(),

        HealthDebuff = self._World:component(),
        DamageDebuff = self._World:component(),
        SpeedDebuff = self._World:component(),
        MitigationDebuff = self._World:component(),

        DamageOverTimeEffect = self._World:component(),
        HealOverTimeEffect = self._World:component(),
        InvinsibilityEffect = self._World:component(),
        ShieldEffect = self._World:component(),
        InvulnerabilityEffect = self._World:component(),
        LifestealBuff = self._World:component(),

        StunEffect = self._World:component(),
        RootEffect = self._World:component(),
        SilenceEffect = self._World:component(),
        FearEffect = self._World:component(),
    }

    -- Tag Names
    self._World:set(self._Tags.Alive, Jecs.Name, "Alive")
    self._World:set(self._Tags.Player, Jecs.Name, "Player")
    self._World:set(self._Tags.NPC, Jecs.Name, "NPC")
    self._World:set(self._Tags.Replicated, Jecs.Name, "Replicated")

    -- Component Names
    self._World:set(self._Components.Name, Jecs.Name, "Name")
    self._World:set(self._Components.Stats, Jecs.Name, "Stats")
    self._World:set(self._Components.Character, Jecs.Name, "Character")
    self._World:set(self._Components.Prefab, Jecs.Name, "Prefab")
    self._World:set(self._Components.Health, Jecs.Name, "Health")
    self._World:set(self._Components.Ether, Jecs.Name, "Ether")
    self._World:set(self._Components.InCombat, Jecs.Name, "InCombat")
    self._World:set(self._Components.Blocking, Jecs.Name, "Blocking")
    self._World:set(self._Components.Dodging, Jecs.Name, "Dodging")
    self._World:set(self._Components.Stunned, Jecs.Name, "Stunned")
    self._World:set(self._Components.CurrentAbility, Jecs.Name, "CurrentAbility")
    self._World:set(self._Components.PreviousAbility, Jecs.Name, "PreviousAbility")
    self._World:set(self._Components.HealthBuff, Jecs.Name, "HealthBuff")
    self._World:set(self._Components.DamageBuff, Jecs.Name, "DamageBuff")
    self._World:set(self._Components.SpeedBuff, Jecs.Name, "SpeedBuff")
    self._World:set(self._Components.MitigationBuff, Jecs.Name, "MitigationBuff")
    self._World:set(self._Components.HealthDebuff, Jecs.Name, "HealthDebuff")
    self._World:set(self._Components.DamageDebuff, Jecs.Name, "DamageDebuff")
    self._World:set(self._Components.SpeedDebuff, Jecs.Name, "SpeedDebuff")
    self._World:set(self._Components.MitigationDebuff, Jecs.Name, "MitigationDebuff")
    self._World:set(self._Components.DamageOverTimeEffect, Jecs.Name, "DamageOverTimeEffect")
    self._World:set(self._Components.HealOverTimeEffect, Jecs.Name, "HealOverTimeEffect")
    self._World:set(self._Components.InvinsibilityEffect, Jecs.Name, "InvinsibilityEffect")
    self._World:set(self._Components.ShieldEffect, Jecs.Name, "ShieldEffect")
    self._World:set(self._Components.InvulnerabilityEffect, Jecs.Name, "InvulnerabilityEffect")
    self._World:set(self._Components.LifestealBuff, Jecs.Name, "LifestealBuff")
    self._World:set(self._Components.StunEffect, Jecs.Name, "StunEffect")
    self._World:set(self._Components.RootEffect, Jecs.Name, "RootEffect")
    self._World:set(self._Components.SilenceEffect, Jecs.Name, "SilenceEffect")
    self._World:set(self._Components.FearEffect, Jecs.Name, "FearEffect")

    -- Replicated Components
    self._World:add(self._Components.Health, self._Tags.Replicated)
    self._World:add(self._Components.Ether, self._Tags.Replicated)
    self._World:add(self._Components.Blocking, self._Tags.Replicated)
    self._World:add(self._Components.Dodging, self._Tags.Replicated)
    self._World:add(self._Components.Stunned, self._Tags.Replicated)
    self._World:add(self._Components.CurrentAbility, self._Tags.Replicated)
    self._World:add(self._Components.PreviousAbility, self._Tags.Replicated)

    self._Systems = self:_GatherAllSystems()

    self.ReplicationSignals = {
        EntityCreated = Signal.new(),
        EntityDeleted = Signal.new(),
    } :: any
end

function EntityServiceServer.Start(self: Module)
    RunService.Heartbeat:Connect(function(dt: number)
        for _, systemModule in self._Systems do
            systemModule:Update({
                World = self._World,
                Tags = self._Tags,
                Components = self._Components,
                Dt = dt
            })
        end
    end)

    Jabby.register({
        applet = Jabby.applets.world,
        name = "Combat",
        configuration = {
            world = self._World
        }
    })
end

return EntityServiceServer :: Module
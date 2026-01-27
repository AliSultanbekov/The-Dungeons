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
}

export type Module = typeof(EntityServiceClient) & ModuleData

-- [ Private Functions ] --
function EntityServiceClient._GatherAllSystems(self: Module): { EntityTypesClient.SystemModule }
    local Systems = {}

    if not SystemsFolder then
        return Systems
    end

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

function EntityServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._World = Jecs.World.new()
    self._Tags = {
        Alive = Jecs.tag(),
        Player = Jecs.tag(),
        NPC = Jecs.tag(),
        Replicated = Jecs.tag(),
    }
    self._Components = {
        Character = self._World:component(),
        Player = self._World:component(),

        Health = self._World:component(),
        Ether = self._World:component(),

        Blocking = self._World:component(),
        Dodging = self._World:component(),
        Stunned = self._World:component(),
        CurrentAbility = self._World:component(),
        PreviousAbility = self._World:component(),
    }

    -- Tag Names
    self._World:set(self._Tags.Alive, Jecs.Name, "Alive")
    self._World:set(self._Tags.Player, Jecs.Name, "Player")
    self._World:set(self._Tags.NPC, Jecs.Name, "NPC")
    self._World:set(self._Tags.Replicated, Jecs.Name, "Replicated")

    -- Component Names
    self._World:set(self._Components.Character, Jecs.Name, "Character")
    self._World:set(self._Components.Player, Jecs.Name, "Player")
    self._World:set(self._Components.Health, Jecs.Name, "Health")
    self._World:set(self._Components.Ether, Jecs.Name, "Ether")
    self._World:set(self._Components.Blocking, Jecs.Name, "Blocking")
    self._World:set(self._Components.Dodging, Jecs.Name, "Dodging")
    self._World:set(self._Components.Stunned, Jecs.Name, "Stunned")
    self._World:set(self._Components.CurrentAbility, Jecs.Name, "CurrentAbility")
    self._World:set(self._Components.PreviousAbility, Jecs.Name, "PreviousAbility")

    self._Systems = self:_GatherAllSystems()
end

function EntityServiceClient.Start(self: Module)
    RunService.RenderStepped:Connect(function(dt: number)
        for _, systemModule in self._Systems do
            systemModule:Update({
                World = self._World,
                Tags = self._Tags,
                Components = self._Components,
                Dt = dt,
            })
        end
    end)
end

return EntityServiceClient :: Module

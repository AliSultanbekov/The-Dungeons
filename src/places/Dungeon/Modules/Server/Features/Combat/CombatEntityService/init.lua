--[=[
    @class CombatEntityService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- [ Imports ] --
local Types = require("@self/_Types")
local TestSystem = require("@self/Systems/_TestSystem")

-- [ Require ] --
local _rbxrequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Jecs = require("Jecs")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatEntityService = {}

-- [ Types ] --
type SystemTemplate = {
    Update: (self: SystemTemplate, context: Types.SystemContext) -> ()
}
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PlayerCharacterManager: typeof(require("PlayerCharacterManager")),
    _World: Jecs.World,
    _Tags: Types.Tags,
    _Components: Types.Components,
    _Systems: {
        [string]: SystemTemplate
    },
    _Order: {
        
    }
}

export type Module = typeof(CombatEntityService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatEntityService.Update(self: Module, dt: number)
    for systemName, systemModule in self._Systems do
        systemModule:Update({
            World = self._World,
            Tags = self._Tags,
            Components = self._Components,
            Dt = dt
        })
    end
end

function CombatEntityService.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    local Player = Players:GetPlayerFromCharacter(character)

    if not Player then
        return
    end

    local World = self._World
    local Tags = self._Tags
    local Components = self._Components

    local Entity = self._World:entity() 
    
    World:add(Entity, Tags.Player)
    World:set(Entity, Components.Health, 100)
    World:set(Entity, Components.Positon, Vector3.new(1,1,1))
    World:set(Entity, Components.PlayerData, {
        Player = Player,
        Character = character
    })
end

function CombatEntityService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PlayerCharacterManager = self._ServiceBag:GetService(require("PlayerCharacterManager"))

    self._World = Jecs.World.new()

    self._Tags = {
        Player = Jecs.tag(),
        NPC = Jecs.tag(),
    }

    self._Components = {
        PlayerData = self._World:component(),
        NPCData = self._World:component(),

        Health = self._World:component(),
        Positon = self._World:component(),

        Blocking = self._World:component(),
        Parrying = self._World:component(),
        Dodging = self._World:component(),
        Stunned = self._World:component(),
    }

    -- TODO: automate
    self._Systems = {
        ["TestSystem"] = TestSystem
    }

    -- TODO: if ordered is needed
    self._Order = {

    }
end

function CombatEntityService.Start(self: Module)
    self._PlayerCharacterManager:RegisterModule(self)

    RunService.Heartbeat:Connect(function(dt: number)
        self:Update(dt)
    end)
end

return CombatEntityService :: Module
--[=[
    @class CreatureRegister
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local EntityTypesClient = require("EntityTypesClient")
local CreatureTypesClient = require("CreatureTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureRegister = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))

type ModuleData = {
    _EntityServiceClient: EntityServiceClient,
    _CharacterToEntity: { [Model]: Jecs.Entity },
    _Signals: CreatureTypesClient.PublicSignals
}

export type Module = typeof(CreatureRegister) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureRegister.GetAllCreatures(self: Module)
    return self._CharacterToEntity
end

function CreatureRegister.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CharacterToEntity[character]
end

function CreatureRegister.Init(self: Module, context: CreatureTypesClient.Init_Context)
    self._EntityServiceClient = context.EntityServiceClient
    self._CharacterToEntity = {}
    self._Signals = context.Signals
end

function CreatureRegister.Start(self: Module)
    self._EntityServiceClient.PublicSignals.EntityCreated:Connect(function(packet: EntityTypesClient.EntityCreatedSignalPacket)
        if not packet.Tags["Creature"] then
            return
        end

        local CharacterComponent = packet.Components.Character

        if not CharacterComponent then
            return
        end

        local Character = CharacterComponent.Character

        if not Character then
            return
        end

        self._CharacterToEntity[Character] = packet.Entity

        self._Signals.CreatureCreated:Fire(Character)
    end)

    self._EntityServiceClient.PublicSignals.EntityDeleted:Connect(function(packet: EntityTypesClient.EntityDeletedSignalPacket)
        if not packet.Tags["Creature"] then
            return
        end

        local CharacterComponent = packet.Components.Character

        if not CharacterComponent then
            return
        end

        local Character = CharacterComponent.Character

        if not Character then
            return
        end

        self._CharacterToEntity[Character] = nil

        self._Signals.CreatureDeleted:Fire(Character)
    end)
end

return CreatureRegister :: Module

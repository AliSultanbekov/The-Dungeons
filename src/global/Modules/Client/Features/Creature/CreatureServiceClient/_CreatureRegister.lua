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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureRegister = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))

type ModuleData = {
    _EntityServiceClient: EntityServiceClient,
    _CharacterToEntity: { [Model]: Jecs.Entity }
}

export type Module = typeof(CreatureRegister) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureRegister.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CharacterToEntity[character]
end

function CreatureRegister.Init(self: Module, entityServiceClient: EntityServiceClient)
    self._EntityServiceClient = entityServiceClient
    self._CharacterToEntity = {}
end

function CreatureRegister.Start(self: Module)
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

return CreatureRegister :: Module

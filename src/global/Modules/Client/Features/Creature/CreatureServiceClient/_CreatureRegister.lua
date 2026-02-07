--[=[
    @class CreatureRegister
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../CreatureTypesClient")

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local EntityTypesClient = require("EntityTypesClient")
local AnimationClass = require("AnimationClass")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureRegister = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))

type ModuleData = {
    _EntityServiceClient: EntityServiceClient,
    _CharacterToEntity: { [Model]: Jecs.Entity },
    PublicSignals: Types.PublicSignals
}

export type Module = typeof(CreatureRegister) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureRegister.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CharacterToEntity[character]
end

function CreatureRegister.Init(self: Module, context: Types.Init_Context)
    self._EntityServiceClient = context.EntityServiceClient
    self._CharacterToEntity = {}

    self.PublicSignals = context.PublicSignals
end

function CreatureRegister.Start(self: Module)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

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

        World:set(packet.Entity, Components.AnimationObject, AnimationClass.new(Character))

        self._CharacterToEntity[Character] = packet.Entity

        self.PublicSignals.CreatureCreated:Fire(Character)
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

        self.PublicSignals.CreatureDeleted:Fire(Character)
    end)
end

return CreatureRegister :: Module

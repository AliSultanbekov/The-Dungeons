--[=[
    @class EntityReplicationServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local EntityTypesShared = require("EntityTypesShared")
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EntityReplicationServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceClient: typeof(require("EntityServiceClient")),
    _EntityNetworkClient: typeof(require("EntityNetworkClient")),
    _ServerToClientEntity: {
        [Jecs.Entity]: Jecs.Entity
    }
}

export type Module = typeof(EntityReplicationServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EntityReplicationServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceClient = self._ServiceBag:GetService(require("EntityServiceClient"))
    self._EntityNetworkClient = self._ServiceBag:GetService(require("EntityNetworkClient"))
    self._ServerToClientEntity = {}
end

function EntityReplicationServiceClient.Start(self: Module)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    self._EntityNetworkClient.RemoteEvents.EntitySync:Connect(function(packet: EntityTypesShared.EntitySyncRemotePacket)
        for _, data in packet do
            if self._ServerToClientEntity[data.Entity] then
                continue
            end

            local Entity = self._EntityServiceClient:CreateEntity({
                Tags = data.Tags,
                Components = data.Components,
            })

            self._ServerToClientEntity[data.Entity] = Entity
        end
    end)

    self._EntityNetworkClient.RemoteEvents.EntityCreated:Connect(function(packet: EntityTypesShared.EntityCreatedRemotePacket)
        if self._ServerToClientEntity[packet.Entity] then
            return
        end

        local Entity = self._EntityServiceClient:CreateEntity({
            Tags = packet.Tags,
            Components = packet.Components,
        })

        self._ServerToClientEntity[packet.Entity] = Entity
    end)

    self._EntityNetworkClient.RemoteEvents.EntityDeleted:Connect(function(packet: EntityTypesShared.EntityDeletedRemotePacket)
        local ClientEntity = self._ServerToClientEntity[packet.Entity]

        if not ClientEntity then
            return
        end

        if not World:exists(ClientEntity) then
            return
        end

        self._EntityServiceClient:DeleteEntity({
            Entity = ClientEntity,
        })

        self._ServerToClientEntity[packet.Entity] = nil
    end)

    self._EntityNetworkClient.RemoteEvents.EntityUpdated:Connect(function(packet: EntityTypesShared.EntityUpdatedRemotePacket)
        if packet.Action == "Added" then
            local Data = packet.Data
            local ClientEntity = self._ServerToClientEntity[Data.Entity]
            local Component = Components[Data.ComponentName]

            if not ClientEntity then
                return
            end

            if not Component then
                return
            end

            if World:has(ClientEntity, Component) then
                return
            end

            World:set(ClientEntity, Component, Data.Value)
        elseif packet.Action == "Updated" then
            local Data = packet.Data
            local ClientEntity = self._ServerToClientEntity[Data.Entity]
            local Component = Components[Data.ComponentName]

            if not ClientEntity then
                return
            end

            if not Component then
                return
            end

            if not World:has(ClientEntity, Component) then
                return
            end

            World:set(ClientEntity, Component, Data.Value)
        elseif packet.Action == "Removed" then
            local Data = packet.Data
            local ClientEntity = self._ServerToClientEntity[Data.Entity]
            local Component = Components[Data.ComponentName]

            if not ClientEntity then
                return
            end

            if not Component then
                return
            end

            if not World:has(ClientEntity, Component) then
                return
            end

            World:remove(ClientEntity, Component)
        end
    end)
end

return EntityReplicationServiceClient :: Module

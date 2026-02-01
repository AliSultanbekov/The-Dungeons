--[=[
    @class EntityReplicationServiceServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local EntityTypesServer = require("EntityTypesServer")
local EntityTypesShared = require("EntityTypesShared")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EntityReplicationServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceServer: typeof(require("EntityServiceServer")),
    _EntityNetworkServer: typeof(require("EntityNetworkServer")),
    _PlayerManager: typeof(require("PlayerManager")),
}

export type Module = typeof(EntityReplicationServiceServer) & ModuleData

-- [ Private Functions ] --
function EntityReplicationServiceServer._EntityCreated(self: Module, EntityData: EntityTypesServer.EntityCreatedSignalPacket)
    local Entity = EntityData.Entity
    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()
    local Components = self._EntityServiceServer:GetComponents()

    local ReplicationValidData = {
        Entity = Entity,
        Tags = EntityData.Tags,
        Components = {},
    }

    for componentName, data in EntityData.Components do
        local Component = Components[componentName]

        if not World:has(Component, Tags.ReplicatedComponent) then
            continue
        end

        ReplicationValidData.Components[componentName] = data
    end

    self._EntityNetworkServer:EntityCreated(ReplicationValidData)
end

function EntityReplicationServiceServer._EntityDeleted(self: Module, EntityData: EntityTypesServer.EntityDeletedSignalPacket)
    self._EntityNetworkServer:EntityDeleted(EntityData)
end

function EntityReplicationServiceServer.GetAllReplicatedEntityData(self: Module)
    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()
    local Components = self._EntityServiceServer:GetComponents()

    local Data = {} :: EntityTypesShared.EntitySyncRemotePacket

    for entity in World:query(Tags.ReplicatedEntity) do
        local EntityData = {
            Entity = entity, 
            Components = {},
            Tags = {},
        }

        for componentName, component in pairs(Components) do
            if not World:has(component, Tags.ReplicatedComponent) then
                continue
            end

            local Component = World:get(entity, component)

            if not Component then
                continue
            end

            EntityData.Components[componentName] = Component
        end

        for tagName, tag in pairs(Tags) do
            if tagName == "ReplicatedComponent" or tagName == "ReplicatedEntity" then
                continue
            end

            if not World:has(entity, tag) then
                continue
            end

            table.insert(EntityData.Tags, tagName)
        end

        table.insert(Data, EntityData)
    end

    return Data
end

-- [ Public Functions ] --
function EntityReplicationServiceServer.OnPlayerAdded(self: Module, maid: Maid.Maid, player: Player)
    self._EntityNetworkServer:EntitySync(self:GetAllReplicatedEntityData())
end

function EntityReplicationServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceServer = self._ServiceBag:GetService(require("EntityServiceServer"))
    self._EntityNetworkServer = self._ServiceBag:GetService(require("EntityNetworkServer"))
    self._PlayerManager = self._ServiceBag:GetService(require("PlayerManager"))
end

function EntityReplicationServiceServer.Start(self: Module)
    self._PlayerManager:RegisterModule(self)

    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()

    -- TODO: setup optimization
    self._EntityServiceServer.PublicSignals.EntityCreated:Connect(function(packet: EntityTypesServer.EntityCreatedSignalPacket) 
        if not packet.Replicated then
            return
        end
         
        self:_EntityCreated(packet)
    end)

    self._EntityServiceServer.PublicSignals.EntityDeleted:Connect(function(packet: EntityTypesServer.EntityDeletedSignalPacket)
        if not packet.Replicated then
            return
        end
            
        self:_EntityDeleted(packet)
    end)

    for component in World:query(Tags.ReplicatedComponent) do
        World:added(component, function(e, _, value)
            self._EntityNetworkServer:EntityUpdated({
                Action = "Added",
                Data = {
                    Entity = e,
                    ComponentName = self._EntityServiceServer._ComponentToName[component],
                    Value = value
                }
            })
        end)

        World:removed(component, function(e, _)
            self._EntityNetworkServer:EntityUpdated({
                Action = "Removed",
                Data = {
                    Entity = e,
                    ComponentName = self._EntityServiceServer._ComponentToName[component],
                }
            })
        end)    

        World:changed(component, function(e, _, value)
            self._EntityNetworkServer:EntityUpdated({
                Action = "Updated",
                Data = {
                    Entity = e,
                    ComponentName = self._EntityServiceServer._ComponentToName[component],
                    Value = value
                }
            })
        end)
    end
end

return EntityReplicationServiceServer :: Module
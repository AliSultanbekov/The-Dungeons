local ServerScriptService = game:GetService("ServerScriptService")
local _WeaponUIBehavior = require(ServerScriptService.Game.Modules.Global.Client.Features.Inventory.InventoryUIService.ItemUIClass.Behaviors.UI._WeaponUIBehavior)
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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EntityReplicationServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceServer: typeof(require("EntityServiceServer")),
    _EntityNetworkServer: typeof(require("EntityNetworkServer")),
}

export type Module = typeof(EntityReplicationServiceServer) & ModuleData

-- [ Private Functions ] --
function EntityReplicationServiceServer.EntityCreated(self: Module, EntityData: EntityTypesServer.EntityCreatedSignalPacket)
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

        if not World:has(Component, Tags.Replicated) then
            return
        end

        ReplicationValidData.Components[componentName] = data
    end

    self._EntityNetworkServer:EntityCreated(ReplicationValidData)
end

function EntityReplicationServiceServer.EntityDeleted(self: Module, EntityData: EntityTypesServer.EntityDeletedSignalPacket)
    self._EntityNetworkServer:EntityDeleted(EntityData)
end

-- [ Public Functions ] --
function EntityReplicationServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceServer = self._ServiceBag:GetService(require("EntityServiceServer"))
    self._EntityNetworkServer = self._ServiceBag:GetService(require("EntityNetworkServer"))
end

function EntityReplicationServiceServer.Start(self: Module)
    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()

    -- TODO: setup optimization
    self._EntityServiceServer.ReplicationSignals.EntityCreated:Connect(function(packet: EntityTypesServer.EntityCreatedSignalPacket)  
        self:EntityCreated(packet)
    end)

    self._EntityServiceServer.ReplicationSignals.EntityDeleted:Connect(function(packet: EntityTypesServer.EntityDeletedSignalPacket)
        self:EntityDeleted(packet)
    end)

    for component in World:query(Tags.Replicated) do
        World:added(component, function(e, _, value)
            self._EntityNetworkServer:EntityUpdated({
                Action = "Added",
                Data = {
                    Entity = e,
                    Component = component,
                    Value = value
                }
            })
        end)

        World:removed(component, function(e, _)
            self._EntityNetworkServer:EntityUpdated({
                Action = "Removed",
                Data = {
                    Entity = e,
                    Component = component,
                }
            })
        end)    

        World:changed(component, function(e, _, value)
            self._EntityNetworkServer:EntityUpdated({
                Action = "Updated",
                Data = {
                    Entity = e,
                    Component = component,
                    Value = value
                }
            })
        end)
    end
end

return EntityReplicationServiceServer :: Module
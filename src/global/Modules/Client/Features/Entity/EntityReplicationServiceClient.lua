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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EntityReplicationServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceClient: typeof(require("EntityServiceClient")),
    _EntityNetworkClient: typeof(require("EntityNetworkClient")),
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
end

function EntityReplicationServiceClient.Start(self: Module)
    local World = self._EntityServiceClient:GetWorld()

    self._EntityNetworkClient:SetOnReplicateComponentChange(function(packet: EntityTypesShared.ReplicateComponentChangeRemotePacket)
        if packet.Action == "Added" then
            local Data = packet.Data
            World:set(Data.Entity, Data.Component, Data.Value)
        elseif packet.Action == "Updated" then
            local Data = packet.Data
            World:set(Data.Entity, Data.Component, Data.Value)
        elseif packet.Action == "Removed" then
            local Data = packet.Data
            if World:has(Data.Entity, Data.Component) then
                World:remove(Data.Entity, Data.Component)
            end
        end
    end)
end

return EntityReplicationServiceClient :: Module

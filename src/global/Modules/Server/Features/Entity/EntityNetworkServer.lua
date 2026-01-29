--[=[
    @class EntityNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local NetworkManager = require("NetworkManager")
local EntityTypesShared = require("EntityTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EntityNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(NetworkManager),

    RemoteEvents: {},
    RemoteFunctions: {}
}

export type Module = typeof(EntityNetworkServer) & ModuleData

-- [ Private Functions ] --
function EntityNetworkServer.EntityCreated(self: Module, packet: EntityTypesShared.EntityCreatedRemotePacket)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")
    EntityChannel:FireAllClients("EntityCreated", packet)
end

function EntityNetworkServer.EntityDeleted(self: Module, packet: EntityTypesShared.EntityDeletedRemotePacket)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")
    EntityChannel:FireAllClients("EntityDeleted", packet)
end

function EntityNetworkServer.EntityUpdated(self: Module, packet: EntityTypesShared.EntityUpdatedRemotePacket)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")
    EntityChannel:FireAllClients("EntityUpdated", packet)
end

function EntityNetworkServer.EntitySync(self: Module, packet: EntityTypesShared.EntitySyncRemotePacket)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")
    EntityChannel:FireAllClients("EntitySync", packet)
end

-- [ Public Functions ] --
function EntityNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(NetworkManager)

    self.RemoteEvents = {

    } :: any

    self.RemoteFunctions = {

    } :: any
end

function EntityNetworkServer.Start(self: Module)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")

    -- Server
    EntityChannel:DeclareEvent("EntityCreated")
    EntityChannel:DeclareEvent("EntityDeleted")
    EntityChannel:DeclareEvent("EntityUpdated")
    EntityChannel:DeclareEvent("EnitytSync")
end

return EntityNetworkServer :: Module
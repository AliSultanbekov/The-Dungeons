--[=[
    @class EntityNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local NetworkManager = require("NetworkManager")
local Signal = require("Signal")
local EntityTypesShared = require("EntityTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EntityNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(NetworkManager),

    RemoteEvents: {
        EntityCreated: Signal.Signal<EntityTypesShared.EntityCreatedRemotePacket>,
        EntityDeleted: Signal.Signal<EntityTypesShared.EntityDeletedRemotePacket>,
        EntityUpdated: Signal.Signal<EntityTypesShared.EntityUpdatedRemotePacket>,
        EntitySync: Signal.Signal<EntityTypesShared.EntitySyncRemotePacket>,
    },
    RemoteFunctions: {}
}

export type Module = typeof(EntityNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EntityNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(NetworkManager)

    self.RemoteEvents = {
        EntityCreated = Signal.new(),
        EntityDeleted = Signal.new(),
        EntityUpdated = Signal.new(),
        EntitySync = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function EntityNetworkClient.Start(self: Module)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")

    EntityChannel:Connect("EntityCreated", function(packet: EntityTypesShared.EntityCreatedRemotePacket)
        self.RemoteEvents.EntityCreated:Fire(packet)
    end)

    EntityChannel:Connect("EntityDeleted", function(packet: EntityTypesShared.EntityDeletedRemotePacket)
        self.RemoteEvents.EntityDeleted:Fire(packet)
    end)

    EntityChannel:Connect("EntityUpdated", function(packet: EntityTypesShared.EntityUpdatedRemotePacket)
        self.RemoteEvents.EntityUpdated:Fire(packet)
    end)

    EntityChannel:Connect("EntitySync", function(packet: EntityTypesShared.EntitySyncRemotePacket)  
        self.RemoteEvents.EntitySync:Fire(packet)
    end)
end

return EntityNetworkClient :: Module
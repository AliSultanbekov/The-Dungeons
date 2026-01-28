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
        EntityUpdated: Signal.Signal<EntityTypesShared.EntityUpdatedRemotePacket>
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
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function EntityNetworkClient.Start(self: Module)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")

    EntityChannel:Connect("EntityUpdated", function(...)  
    end)
end

return EntityNetworkClient :: Module
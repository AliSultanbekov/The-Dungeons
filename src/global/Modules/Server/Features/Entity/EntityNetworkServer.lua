--[=[
    @class EntityNetworkServer
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
local EntityNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
}

export type Module = typeof(EntityNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EntityNetworkServer.ReplicateComponentChange(self: Module, packet: EntityTypesShared.ReplicateComponentChangeRemotePacket)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")
    EntityChannel:FireAllClients("ReplicateComponentChange", packet)
end

function EntityNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(require("NetworkManager"))
end

function EntityNetworkServer.Start(self: Module)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")
    EntityChannel:DeclareEvent("ReplicateComponentChange")
end

return EntityNetworkServer :: Module
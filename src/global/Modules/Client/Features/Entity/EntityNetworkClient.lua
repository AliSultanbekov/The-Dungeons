--[=[
    @class EntityNetworkClient
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
local EntityNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
    _OnReplicateComponentChange: ((packet: EntityTypesShared.ReplicateComponentChangeRemotePacket) -> ())?,
}

export type Module = typeof(EntityNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EntityNetworkClient.SetOnReplicateComponentChange(
    self: Module,
    callback: (packet: EntityTypesShared.ReplicateComponentChangeRemotePacket) -> ()
)
    self._OnReplicateComponentChange = callback
end

function EntityNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(require("NetworkManager"))
end

function EntityNetworkClient.Start(self: Module)
    local EntityChannel = self._NetworkManager:GetNetwork("Entity")

    EntityChannel:Connect("ReplicateComponentChange", function(packet: EntityTypesShared.ReplicateComponentChangeRemotePacket)
        if self._OnReplicateComponentChange then
            self._OnReplicateComponentChange(packet)
        end
    end)
end

return EntityNetworkClient :: Module

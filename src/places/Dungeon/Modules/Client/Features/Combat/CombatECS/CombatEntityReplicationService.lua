--[=[
    @class CombatEntityReplicationServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatEntityReplicationServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatNetworkClient: typeof(require("CombatNetworkClient")),
    _CombatEntityServiceClient: typeof(require("CombatEntityServiceClient"))
}

export type Module = typeof(CombatEntityReplicationServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatEntityReplicationServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatNetworkClient = self._ServiceBag:GetService(require("CombatNetworkClient"))
    self._CombatEntityServiceClient = self._ServiceBag:GetService(require("CombatEntityServiceClient"))
end

function CombatEntityReplicationServiceClient.Start(self: Module)
    local World = self._CombatEntityServiceClient:GetWorld()

    self._CombatNetworkClient.RemoteEvents.EntityStateChanged:Connect(function(packet: CombatTypes.EntityStateUpdatedRemotePacket)
        if not packet then
            return
        end

        if packet.Action == "Added" then
            local Data = packet.Data
            World:set(Data.Entity, Data.Component, Data.Value)
        elseif packet.Action == "Removed" then
            local Data = packet.Data
            World:remove(Data.Entity, Data.Component)
        elseif packet.Action == "Updated" then
            local Data = packet.Data
            World:set(Data.Entity, Data.Component, Data.Value)
        end
    end)
end

return CombatEntityReplicationServiceClient :: Module
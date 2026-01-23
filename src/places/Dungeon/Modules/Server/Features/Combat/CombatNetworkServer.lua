--[=[
    @class CombatNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatNetworkServer = {}

-- [ Types ] --
type Context = CombatTypes.Context

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
    RemoteEvents: {
        UseAbility: Signal.Signal<Player, CombatTypes.UseAbilityRemotePacket>,
        EndAbility: Signal.Signal<Player, CombatTypes.EndAbilityRemotePacket>,
        HitAbility: Signal.Signal<Player, CombatTypes.HitAbilityRemotePacket>,
    },
    RemoteFunctions: {
        
    }
}

export type Module = typeof(CombatNetworkServer) & ModuleData

-- [ Private Functions ] --
function CombatNetworkServer.EntityStateUpdated(self: Module, packet: CombatTypes.EntityStateUpdatedRemotePacket)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireAllClients("EntityStateUpdated", packet)
end

function CombatNetworkServer.AbilityHit(self: Module, packet: CombatTypes.AbilityHitRemotePacket)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireAllClients("AbilityHit", packet)
end

-- [ Public Functions ] --
function CombatNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(require("NetworkManager"))
    self.RemoteEvents = {
        UseAbility = Signal.new(),
        EndAbility = Signal.new(),
        HitAbility = Signal.new()
    } :: any
    self.RemoteFunctions = {

    } :: any
end

function CombatNetworkServer.Start(self: Module)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")

    -- client
    CombatChannel:DeclareEvent("UseAbility")
    CombatChannel:DeclareEvent("EndAbility")
    CombatChannel:DeclareEvent("HitAbility")
    -- server
    CombatChannel:DeclareEvent("AbilityHit")
    CombatChannel:DeclareEvent("EntityStateUpdated")

    CombatChannel:Connect("UseAbility", function(player: Player, packet: CombatTypes.UseAbilityRemotePacket)
        self.RemoteEvents.UseAbility:Fire(player, packet)
    end)

    CombatChannel:Connect("EndAbility", function(player: Player, packet: CombatTypes.EndAbilityRemotePacket)
        self.RemoteEvents.EndAbility:Fire(player, packet)
    end)

    CombatChannel:Connect("HitAbility", function(player: Player, packet: CombatTypes.HitAbilityRemotePacket)
        self.RemoteEvents.HitAbility:Fire(player, packet)
    end)
end

return CombatNetworkServer :: Module
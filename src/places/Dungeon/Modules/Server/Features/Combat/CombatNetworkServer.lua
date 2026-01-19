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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
    RemoteEvents: {
        UseAbility: Signal.Signal<Player, {[any]: any}?>,
        EndAbility: Signal.Signal<Player, {[any]: any}?>,
        HitAbility: Signal.Signal<Player, {[any]: any}?>,
    },
    RemoteFunctions: {

    }
}

export type Module = typeof(CombatNetworkServer) & ModuleData

-- [ Private Functions ] --
function CombatNetworkServer.AbilityUsed(self: Module, params: {[any]: any}?)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireAllClients("AbilityUsed", params)
end

function CombatNetworkServer.AbilityEnded(self: Module, params: {[any]: any}?)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireAllClients("AbilityEnded", params)
end

function CombatNetworkServer.AbilityHit(self: Module, params: {[any]: any}?)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireAllClients("AbilityUsed", params)
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
    CombatChannel:DeclareEvent("AbilityUsed")
    CombatChannel:DeclareEvent("AbilityEnded")
    CombatChannel:DeclareEvent("AbilityHit")

    CombatChannel:Connect("UseAbility", function(player: Player, params: {[any]: any}?)
        self.RemoteEvents.UseAbility:Fire(player, params)
    end)

    CombatChannel:Connect("EndAbility", function(player: Player, params: {[any]: any}?)
        self.RemoteEvents.EndAbility:Fire(player, params)
    end)

    CombatChannel:Connect("HitAbility", function(player: Player, params: {[any]: any}?)
        self.RemoteEvents.HitAbility:Fire(player, params)
    end)
end

return CombatNetworkServer :: Module
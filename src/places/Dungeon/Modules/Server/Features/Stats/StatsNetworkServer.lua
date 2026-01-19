--[=[
    @class StatsNetworkServer
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
local StatsNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
    RemoteEvents: {},
    RemoteFunctions: {
        GetPlayerRawStats: (player: Player) -> (),
        GetPlayerPrimaryStats: (player: Player) -> (),
    }
}

export type Module = typeof(StatsNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function StatsNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function StatsNetworkServer.Start(self: Module)
    print("Trreiied")
    local CombatChannel = self._NetworkManager:GetNetwork("Stats")

    -- client
    CombatChannel:DeclareMethod("GetPlayerRawStats")
    CombatChannel:DeclareMethod("GetPlayerPrimaryStats")

    CombatChannel:Bind("GetPlayerRawStats", function(player: Player)
        return self.RemoteFunctions.GetPlayerRawStats(player)
    end)

    CombatChannel:Bind("GetPlayerPrimaryStats", function(player: Player)
        return self.RemoteFunctions.GetPlayerPrimaryStats(player)
    end)
end

return StatsNetworkServer :: Module
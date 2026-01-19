--[=[
    @class StatsService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local StatTypes = require("StatsTypes")
local StatsCalculationUtility = require("StatsCalculationUtility")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StatsService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _StatsNetworkServer: typeof(require("StatsNetworkServer")),
    _DataManager:  typeof(require("DataManager")),
}

export type Module = typeof(StatsService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function StatsService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._StatsNetworkServer = self._ServiceBag:GetService(require("StatsNetworkServer"))
    self._DataManager = self._ServiceBag:GetService(require("DataManager"))
end

function StatsService.Start(self: Module)
    self._StatsNetworkServer.RemoteFunctions.GetPlayerRawStats = function(player : Player)
        local isValid, data : StatTypes.PrimaryStats = self._DataManager:GetData(player,  "PrimaryStats")
        if not isValid then
            return warn(`No data for player {player.Name}`)
        end

        return table.clone(data)
    end

    self._StatsNetworkServer.RemoteFunctions.GetPlayerPrimaryStats = function(player : Player)
        local isValid, data : StatTypes.PrimaryStats = self._DataManager:GetData(player,  "RawStats")
        if not isValid then
            return warn(`No data for player {player.Name}`)
        end

        local stat : StatTypes.PlayerStats = {
            RawStats = {} :: StatTypes.RawStats,
            PrimaryStats = data :: StatTypes.PrimaryStats,
        }

        StatsCalculationUtility:UpdateStats(stat)

        return table.clone(stat.RawStats)
    end
end

return StatsService :: Module
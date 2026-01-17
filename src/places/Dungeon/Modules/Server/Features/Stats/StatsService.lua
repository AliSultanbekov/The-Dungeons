--[=[
    @class CombatService
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
local GET_PLAYER_RAW_STATS = "GetPlayerRawStats"
local GET_PLAYER_PRIMARY_STATS = "GetPlayerPrimaryStats"
local GET_STATS_SERVICE_CHANNEL = "StatsServiceChannel"

-- [ Variables ] --

-- [ Module Table ] --
local CombatService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkService: typeof(require("NetworkService")),
    _DataService :  typeof(require("DataService")),
}

export type Module = typeof(CombatService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkService = self._ServiceBag:GetService(require("NetworkService"))
    self._DataService = self._ServiceBag:GetService(require("DataService"))
end

function CombatService.Start(self: Module)
    local networkChannel = self._NetworkService:GetNetwork(GET_STATS_SERVICE_CHANNEL)
    
    networkChannel:Bind(GET_PLAYER_PRIMARY_STATS, function(player : Player)
        local isValid, data : StatTypes.PrimaryStats = self._DataService:GetData(player,  "PrimaryStats")
        if not isValid then
            return warn(`No data for player {player.Name}`)
        end

        return table.clone(data)
    end)

    networkChannel:Bind(GET_PLAYER_RAW_STATS, function(player : Player)
        local isValid, data : StatTypes.PrimaryStats = self._DataService:GetData(player,  "RawStats")
        if not isValid then
            return warn(`No data for player {player.Name}`)
        end

        local stat : StatTypes.PlayerStats = {
            RawStats = {} :: StatTypes.RawStats,
            PrimaryStats = data :: StatTypes.PrimaryStats,
        }

        StatsCalculationUtility:UpdateStats(stat)

        return table.clone(stat.RawStats)
    end)
end

return CombatService :: Module
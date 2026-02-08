--[=[
    @class TimeUtil
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local GeneralGameConstants = require("GeneralGameConstants")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TimeUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(TimeUtil) & ModuleData

-- [ Private Functions ] --
function TimeUtil.GetSyncedTime(self: Module, player: Player): number
    local BaseTime = workspace:GetServerTimeNow()
    local ProcessingDelay = GeneralGameConstants.ProcessingPingDelay
    
    if not player then
        return BaseTime
    end
    
    local Ping = player:GetNetworkPing() / 2
    local SyncedTime: number

    if RunService:IsServer() then
        SyncedTime = BaseTime - ProcessingDelay - Ping
    else
        SyncedTime = BaseTime + ProcessingDelay + Ping
    end

    warn(string.format(
        "[TimeUtil] GetSyncedTime %s | BaseTime=%.2f ProcessingDelay=%.2f Ping=%.2f SyncedTime=%.2f",
        RunService:IsServer() and "Server" or "Client",
        BaseTime,
        ProcessingDelay,
        Ping,
        SyncedTime
    ))

    return SyncedTime
end

function TimeUtil.GetTime(self: Module)
    return workspace:GetServerTimeNow()
end

-- [ Public Functions ] --

return TimeUtil :: Module
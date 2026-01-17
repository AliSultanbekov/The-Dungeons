--[=[
    @class CombatConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatConfig = {
    PingAdditionalDelay = 0.05,
    BaseAngle = math.rad(90),
    AnglePer100ms = math.rad(30),
    DistanceTolerance = 4,
    EndGracePeriod = 0.12,
}

-- [ Types ] --
export type Module = typeof(CombatConfig)

return CombatConfig :: Module
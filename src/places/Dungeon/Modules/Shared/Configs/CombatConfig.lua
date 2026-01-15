--[=[
    @class CombatConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatConfig = {
    DistanceTolerance = 2.5,
    AngleTolerance = 0.2
}

-- [ Types ] --
export type Module = typeof(CombatConfig)

return CombatConfig :: Module
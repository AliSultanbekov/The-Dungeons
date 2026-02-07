--[=[
    @class ItemConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GameConsants = {
    MAX_LEVEL = 100,

    ProcessingPingDelay = 0.06
}

-- [ Types ] --
export type Module = typeof(GameConsants)

return GameConsants :: Module
--[=[
    @class ItemConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = _require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GameConsants = {
    MAX_LEVEL = 100,
    WORLD_ENTITY = Jecs.World.new(),
}

-- [ Types ] --
export type Module = typeof(GameConsants)

return GameConsants :: Module
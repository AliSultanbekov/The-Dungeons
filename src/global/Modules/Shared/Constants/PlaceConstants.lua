--[=[
    @class PlaceConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlaceConstants = {
    Places = {
        Hub = 107299473436919,
        Dungeon = 74225058208807,
    },
    
    PlaceIDToPlaceName = {
        [107299473436919] = "Hub",
        [74225058208807] = "Dungeon",
    }
}

-- [ Types ] --
export type Module = typeof(PlaceConstants)

return PlaceConstants :: Module
--[=[
    @class SmartMap
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local SmartMap = {}

-- [ Types ] --
export type MapData<T> = {
    Added: { [string]: T },
    Updated: { [string]: T },
    Removed: { [string]: T },
}

export type Module = typeof(SmartMap)

-- [ Private Functions ] --

-- [ Public Functions ] --
function SmartMap.Transform(self: Module, added: {}?, updated: {}?, removed: {}?)
    local MapData = {}
    local Added = added or {}
    local Updated = updated or {}
    local Removed = removed or {}

    MapData.Added = Added
    MapData.Updated = Updated
    MapData.Removed = Removed

    return MapData
end

return SmartMap :: Module
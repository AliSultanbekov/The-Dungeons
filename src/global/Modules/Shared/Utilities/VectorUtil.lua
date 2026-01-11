--[=[
    @class VectorUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local VectorUtil = {}

-- [ Types ] --
export type Module = typeof(VectorUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function VectorUtil.FlattenV3(self: Module, v: Vector3, transformer: Vector3)
    return v * transformer.Unit
end

return VectorUtil :: Module
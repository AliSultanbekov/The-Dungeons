--[=[
    @class TestSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../_Types")

-- [ Require ] --
local require = require(script.Parent.Parent.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local BlockSystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(BlockSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function BlockSystem.Update(self: Module, context: Types.SystemContext)

end

return BlockSystem :: Module
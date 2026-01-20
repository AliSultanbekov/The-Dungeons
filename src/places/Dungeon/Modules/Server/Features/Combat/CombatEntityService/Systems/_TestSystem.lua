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
local TestSystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(TestSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TestSystem.Update(self: Module, context: Types.SystemContext)
end

return TestSystem :: Module
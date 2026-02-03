--[=[
    @class CreatureGeneric
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureGeneric = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(CreatureGeneric) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureGeneric.Init(self: Module)

end

function CreatureGeneric.Start(self: Module)

end

return CreatureGeneric :: Module

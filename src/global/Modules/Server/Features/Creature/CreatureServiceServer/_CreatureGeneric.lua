--[=[
    @class CreatureGeneric
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../CreatureTypesServer")

-- [ Require ] --
local _require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureGeneric = {}

-- [ Types ] --
type EntityServiceServer = typeof(require("EntityServiceServer"))
type ModuleData = {
    _EntityServiceServer: EntityServiceServer,
    PublicSignals: Types.PublicSignals
}

export type Module = typeof(CreatureGeneric) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureGeneric.Init(self: Module, context: Types.Init_Context)
    self._EntityServiceServer = context.EntityServiceServer
    self.PublicSignals = context.PublicSignals
end

function CreatureGeneric.Start(self: Module)

end

return CreatureGeneric :: Module
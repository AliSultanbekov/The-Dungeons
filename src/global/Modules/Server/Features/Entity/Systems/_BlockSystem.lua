--[=[
    @class BlockSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesServer = require("EntityTypesServer")
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local BlockSystem = {}

-- [ Types ] --
type ModuleData = {
    _World: Jecs.World,
    _Tags: EntityTypesServer.Tags,
    _Components: EntityTypesServer.Components,
    _Signals: EntityTypesServer.PublicSignals,
}

export type Module = typeof(BlockSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function BlockSystem.Update(self: Module, dt: number)
    local World = self._World
    local Tags = self._Tags
    local Components = self._Components
    for entity in World:query(Tags.Creature, Components.Blocking) do
        local Ether = World:get(entity, Components.Ether) :: EntityTypesServer.EtherComponent
        if Ether <= 0 then
            World:remove(entity, Components.Blocking)
        end
    end
end

function BlockSystem.Init(self: Module, context: EntityTypesServer.SystemModule_Init_Context)
    self._World = context.World
    self._Tags = context.Tags
    self._Components = context.Components
    self._Signals = context.Signals
end

return BlockSystem :: Module
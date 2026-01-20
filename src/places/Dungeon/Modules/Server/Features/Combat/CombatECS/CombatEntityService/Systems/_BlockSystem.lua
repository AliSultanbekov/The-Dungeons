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
    local World = context.World
    local Tags = context.Tags
    local Components = context.Components
    for entity in World:query(Tags.Alive, Components.Blocking, Components.Ether) do
        local Ether = World:get(entity, Components.Ether) :: Types.EtherComponent

        if Ether <= 0 then
            World:remove(entity, Components.Blocking)
        end
    end
end

return BlockSystem :: Module
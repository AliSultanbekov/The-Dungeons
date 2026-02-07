--[=[
    @class TestSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesServer = require("EntityTypesServer")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local BlockSystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(BlockSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function BlockSystem.Update(self: Module, context: EntityTypesServer.SystemModuleUpdateContext)
    local World = context.World
    local Tags = context.Tags
    local Components = context.Components
    for entity in World:query(Tags.Creature, Components.Blocking) do
        local Ether = World:get(entity, Components.Ether) :: EntityTypesServer.EtherComponent
        if Ether <= 0 then
            World:remove(entity, Components.Blocking)
        end
    end
end

return BlockSystem :: Module
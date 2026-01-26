--[=[
    @class TestSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../../_Types")

-- [ Require ] --
local _require = require(script.Parent.Parent.Parent.loader).load(script)

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
    for entity, _, currentAbility in World:query(Tags.Alive, Components.CurrentAbility) do
        if currentAbility.StartTime + currentAbility.Duration < os.clock() then
            World:set(entity, Components.PreviousAbility, table.clone(currentAbility))
            World:remove(entity, Components.CurrentAbility)

            if currentAbility.AbilityName == "Block" then
                World:remove(entity, Components.Blocking)
            end
        end
    end
end

return BlockSystem :: Module
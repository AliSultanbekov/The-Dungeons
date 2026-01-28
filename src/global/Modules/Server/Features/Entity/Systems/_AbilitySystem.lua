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
local AbilitySystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(AbilitySystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function AbilitySystem.Update(self: Module, context: EntityTypesServer.SystemModuleUpdateContext)
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

return AbilitySystem :: Module
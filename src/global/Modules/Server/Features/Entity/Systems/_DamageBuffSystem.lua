--[=[
    @class TestSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesServer = require("EntityTypesServer")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DamageBuffSystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(DamageBuffSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function DamageBuffSystem.Update(self: Module, context: EntityTypesServer.SystemModuleUpdateContext)
    local World = context.World
    --local Tags = context.Tags
    local Components = context.Components

    for Entity, DamageBuff: EntityTypesServer.DamageBuffComponent in World:query(Components.DamageBuff) do
        if DamageBuff.StartTime + DamageBuff.Duration < os.clock() then
            World:remove(Entity, Components.DamageBuff)
        end
    end
end

return DamageBuffSystem :: Module
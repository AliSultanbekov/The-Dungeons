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
local HealthSystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(HealthSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function HealthSystem.Update(self: Module, context: Types.SystemContext)
    local World = context.World
    local Tags = context.Tags
    local Components = context.Components
    for entity, _, health in World:query(Tags.Alive, Components.Health) do
        local PlayerData = World:get(entity, Components.PlayerData)
        local NPCData = World:get(entity, Components.NPCData)

        if PlayerData then
            if PlayerData.Humanoid.Health == nil then
                return
            end

            PlayerData.Humanoid.Health = health
        elseif NPCData then
            if NPCData.Humanoid.Health == nil then
                return
            end

            NPCData.Humanoid.Health = health
        end
    end
end

return HealthSystem :: Module
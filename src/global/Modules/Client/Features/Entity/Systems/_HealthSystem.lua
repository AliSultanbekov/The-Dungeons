--[=[
    @class TestSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesServer = require("EntityTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HealthSystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(HealthSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function HealthSystem.Update(self: Module, context: EntityTypesServer.SystemModuleUpdateContext)
    local World = context.World
    local Tags = context.Tags
    local Components = context.Components
    for entity, _, character, health in World:query(Tags.Alive, Components.Character, Components.Health) do
        if character.Humanoid.Health == nil then
            continue
        end

        if character.Humanoid.Health == health then
            continue
        end

        character.Humanoid.Health = health
    end

    --[[RunService.Heartbeat:Connect(function(dt: number)
        for entityId, combatStats in self._JecsWorld:query(ComponentConstants.CombatStats) do
            local rawStats = combatStats.RawStats
            local maxHealth = rawStats.MaxHealth
            local healthRegenRate = rawStats.HealthRegen
            local currentHealth = rawStats.Health

            local healthToRegen = ((healthRegenRate) * dt)
            local newHealth = math.clamp(currentHealth + healthToRegen, 0, maxHealth)

            if self._JecsWorld:has(entityId, ComponentConstants.InCombatComponent) then 
                newHealth = newHealth * .025
            end
            
            rawStats.Health = newHealth
        end

        for entityId, combatComponent : InCombatComponent in self._JecsWorld:query(ComponentConstants.InCombatComponent) do
            if combatComponent.CurrentDuration < combatComponent.Duration then
                combatComponent.CurrentDuration = combatComponent.CurrentDuration + dt
            else
                self._JecsWorld:remove(entityId, ComponentConstants.InCombatComponent)
            end
        end
    end)]]
end

return HealthSystem :: Module
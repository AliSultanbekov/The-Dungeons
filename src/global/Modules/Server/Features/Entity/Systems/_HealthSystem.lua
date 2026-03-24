--[=[
    @class HealthSystem
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
local HealthSystem = {}

-- [ Types ] --
type ModuleData = {
    _World: Jecs.World,
    _Tags: EntityTypesServer.Tags,
    _Components: EntityTypesServer.Components,
    _Signals: EntityTypesServer.PublicSignals,
}

export type Module = typeof(HealthSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function HealthSystem.Update(self: Module, dt: number)
    local World = self._World
    local Tags = self._Tags
    local Components = self._Components
    for entity, _, character, health in World:query(Tags.Creature, Components.Character, Components.Health) do
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

function HealthSystem.Init(self: Module, context: EntityTypesServer.SystemModule_Init_Context)
    self._World = context.World
    self._Tags = context.Tags
    self._Components = context.Components
    self._Signals = context.Signals
end

return HealthSystem :: Module
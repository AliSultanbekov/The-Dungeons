--[=[
    @class EffectSystem
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
local EffectSystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(EffectSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EffectSystem.Update(self: Module, context: EntityTypesServer.SystemModuleUpdateContext)
    local World = context.World
    local Components = context.Components
    local Dt = context.Dt

    for Entity, Effect: EntityTypesServer.OverTimeEffectComponent, Health: EntityTypesServer.HealthComponent in
        World:query(Components.DamageOverTimeEffect, Components.Health)
    do
        if Effect.StartTime + Effect.Duration < os.clock() then
            World:remove(Entity, Components.DamageOverTimeEffect)
        else
            local DamagePerSecond = Effect.TotalAmount / Effect.Duration
            local NewHealth = math.max(Health - (DamagePerSecond * Dt), 0)
            World:set(Entity, Components.Health, NewHealth)
        end
    end

    for Entity, Effect: EntityTypesServer.OverTimeEffectComponent, Health: EntityTypesServer.HealthComponent in
        World:query(Components.HealOverTimeEffect, Components.Health)
    do
        if Effect.StartTime + Effect.Duration < os.clock() then
            World:remove(Entity, Components.HealOverTimeEffect)
        else
            local HealPerSecond = Effect.TotalAmount / Effect.Duration
            local NewHealth = Health + (HealPerSecond * Dt)
            World:set(Entity, Components.Health, NewHealth)
        end
    end
end

return EffectSystem :: Module
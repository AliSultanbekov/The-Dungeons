--[=[
    @class EffectSystem
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
local EffectSystem = {}

-- [ Types ] --
type ModuleData = {
    _World: Jecs.World,
    _Tags: EntityTypesServer.Tags,
    _Components: EntityTypesServer.Components,
    _Signals: EntityTypesServer.PublicSignals,
}

export type Module = typeof(EffectSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EffectSystem.Update(self: Module, dt: number)
    local World = self._World
    local Components = self._Components

    for Entity, Effect: EntityTypesServer.OverTimeEffectComponent, Health: EntityTypesServer.HealthComponent in
        World:query(Components.DamageOverTimeEffect, Components.Health)
    do
        if Effect.StartTime + Effect.Duration < os.clock() then
            World:remove(Entity, Components.DamageOverTimeEffect)
        else
            local DamagePerSecond = Effect.TotalAmount / Effect.Duration
            local NewHealth = math.max(Health - (DamagePerSecond * dt), 0)
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
            local NewHealth = Health + (HealPerSecond * dt)
            World:set(Entity, Components.Health, NewHealth)
        end
    end
end

function EffectSystem.Init(self: Module, context: EntityTypesServer.SystemModule_Init_Context)
    self._World = context.World
    self._Tags = context.Tags
    self._Components = context.Components
    self._Signals = context.Signals
end

return EffectSystem :: Module
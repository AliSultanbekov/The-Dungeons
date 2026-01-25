--[=[
    @class HealthRegenService
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local ComponentConstants = require("ComponentConstants")

local GeneralGameConstants = require("GeneralGameConstants")
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HealthRegenService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _JecsWorld: Jecs.World,
}


export type Module = typeof(HealthRegenService) & ModuleData

export type InCombatComponent = {
    Duration : number,
    CurrentDuration : number,
}
-- [ Private Functions ] --

-- [ Public Functions ] --
function HealthRegenService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    warn("HealthRegenService Init called")
    

    self._JecsWorld = GeneralGameConstants.WORLD_ENTITY
    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function HealthRegenService.Start(self: Module)
    RunService.Heartbeat:Connect(function(dt: number)
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
    end)
end

return HealthRegenService :: Module
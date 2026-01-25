--[=[
    @class OverTimeEffectService
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
local OverTimeEffectService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _JecsWorld: Jecs.World,
}

export type OTEffect = {
    Duration : number,
    EffectTime : number,
    Ticks : number,
    EffectAmount : number
}

export type Module = typeof(OverTimeEffectService) & ModuleData

-- [ Private Functions ] --
local function processOverTimeEffect(
    world: Jecs.World,
    entityId: any,
    combatStats: any,
    effect: OTEffect,
    componentType: any,
    dt: number,
    isDamage: boolean
)
    local rawStats = combatStats.RawStats
    local maxHealth = rawStats.MaxHealth
    local currentHealth = rawStats.Health or 0
    
    local duration = effect.Duration
    local effectTime = effect.EffectTime
    local ticks = effect.Ticks
    local effectAmount = effect.EffectAmount
    
    -- Calculate tick interval and current tick
    local tickInterval = duration / ticks
    local previousTick = math.floor(effectTime / tickInterval)
    
    -- Update effect time
    local newEffectTime = effectTime + dt
    local currentTick = math.floor(newEffectTime / tickInterval)
    
    -- Apply effect if we crossed a tick boundary
    if currentTick > previousTick and currentTick <= ticks then
        local newHealth
        if isDamage then
            newHealth = math.max(currentHealth - effectAmount, 0)
        else
            newHealth = math.min(currentHealth + effectAmount, maxHealth)
        end
        rawStats.Health = newHealth
    end
    
    -- Check if effect has expired
    if newEffectTime >= duration then
        world:remove(entityId, componentType)
    else
        -- Update the effect time
        world:set(entityId, componentType, {
            Duration = duration,
            EffectTime = newEffectTime,
            Ticks = ticks,
            EffectAmount = effectAmount,
        })
    end
end

-- [ Public Functions ] --
function OverTimeEffectService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    
    self._JecsWorld = GeneralGameConstants.WORLD_ENTITY
    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function OverTimeEffectService.Start(self: Module)  
    local lookingFor = {
        ComponentConstants.CombatStats,
        ComponentConstants.Prefab,
    }

    RunService.Heartbeat:Connect(function(dt: number)  
   
        task.spawn(function()
         for entityId, combatStats, HOT : OTEffect in self._JecsWorld:query(unpack(lookingFor), ComponentConstants.HealOverTimeEffect) do         
                warn(entityId, combatStats, HOT )
              processOverTimeEffect(
                    self._JecsWorld,
                    entityId,
                    combatStats,
                    HOT,
                    ComponentConstants.HealOverTimeEffect,
                    dt,
                    false
                )
            end   
        end)

        task.spawn(function()
         for entityId, combatStats, DOT : OTEffect in self._JecsWorld:query(unpack(lookingFor), ComponentConstants.DamageOverTimeEffect) do         
                warn(entityId, combatStats, DOT )
                processOverTimeEffect(
                    self._JecsWorld,
                    entityId,
                    combatStats,
                    DOT,
                    ComponentConstants.DamageOverTimeEffect,
                    dt,
                    true
                )
            end   
        end)
    end)
end

return OverTimeEffectService :: Module
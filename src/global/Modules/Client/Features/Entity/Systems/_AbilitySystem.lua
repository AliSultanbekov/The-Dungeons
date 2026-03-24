--[=[
    @class AbilitySystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesClient = require("EntityTypesClient")
local AbilityConfig = require("AbilityConfig")
local Jecs = require("Jecs")
local TimeUtil = require("TimeUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AbilitySystem = {}

-- [ Types ] --
type ModuleData = {
    _World: Jecs.World,
    _Tags: EntityTypesClient.Tags,
    _Components: EntityTypesClient.Components,
    _Signals: EntityTypesClient.PublicSignals,
}

export type Module = typeof(AbilitySystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function AbilitySystem.Update(self: Module, dt: number)
    local World = self._World
    local Tags = self._Tags
    local Components = self._Components
    
    -- Cooldowns Handling
    for entity, _, abilityCooldowns in World:query(Tags.Creature, Components.AbilityCooldowns) do
        local Changed = false
        local ServerTime = TimeUtil:GetTime()

        for abilityName, endTime in abilityCooldowns do
            if endTime < ServerTime then
                Changed = true
                abilityCooldowns[abilityName] = nil
            end
        end

        if Changed then
            World:set(entity, Components.AbilityCooldowns, abilityCooldowns)
        end
    end

    -- Ability Expiry Handling
    for entity, _, currentAbilities: EntityTypesClient.CurrentAbilities, previousAbilities: EntityTypesClient.PreviousAbilities in World:query(Tags.Creature, Components.CurrentAbilities, Components.PreviousAbilities) do
        local ServerTime = TimeUtil:GetTime()
        local ExpiredAbilities = {}

        for abilityName, abilityData: EntityTypesClient.BaseAbility in currentAbilities do
            if abilityData.StartTime + abilityData.Duration <= ServerTime then
                ExpiredAbilities[abilityName] = abilityData
                previousAbilities[abilityName] = table.clone(abilityData)
                currentAbilities[abilityName] = nil
            end
        end

        if next(ExpiredAbilities) == nil then
            continue
        end

        World:set(entity, Components.PreviousAbilities, previousAbilities)
        World:set(entity, Components.CurrentAbilities, currentAbilities)

        for _, abilityData in ExpiredAbilities do
            local AbilityConfigData = AbilityConfig.Abilities[abilityData.AbilityName]
            local AbilityComponents = AbilityConfigData.Components

            if AbilityComponents then
                for _, componentName in AbilityComponents do
                    World:remove(entity, Components[componentName])
                end
            end

            self._Signals.AbilityExpired:Fire({
                Entity = entity,
                AbilityData = abilityData
            })
        end
    end

    -- Parry Stun Handling
    for entity, _, parryStunned: EntityTypesClient.ParryStunnedComponent in World:query(Tags.Creature, Components.ParryStunned) do
        local ServerTime = TimeUtil:GetTime()

        if parryStunned <= ServerTime then
            World:remove(entity, Components.ParryStunned)
        end
    end

    -- Movement Handling
    for entity, _, character: EntityTypesClient.CharacterComponent in World:query(Tags.Creature, Components.Character) do
        local CurrentAbilities = World:get(entity, Components.CurrentAbilities)

        if not CurrentAbilities then
            continue
        end

        if next(CurrentAbilities) ~= nil then
            character.Humanoid.WalkSpeed = 10
        else
            character.Humanoid.WalkSpeed = 16
        end
    end
end

function AbilitySystem.Init(self: Module, context: EntityTypesClient.SystemModule_Init_Context)
    self._World = context.World
    self._Tags = context.Tags
    self._Components = context.Components
    self._Signals = context.Signals
end

return AbilitySystem :: Module
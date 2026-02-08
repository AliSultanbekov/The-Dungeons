--[=[
    @class TestSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesServer = require("EntityTypesServer")
local AbilityConfig = require("AbilityConfig")
local TimeUtil = require("TimeUtil")

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
    for entity, _, currentAbilities: EntityTypesServer.CurrentAbilities, previousAbilities: EntityTypesServer.PreviousAbilities in World:query(Tags.Creature, Components.CurrentAbilities, Components.PreviousAbilities) do
        local ServerTime = TimeUtil:GetTime()
        local ExpiredAbilities = {}

        for abilityName, abilityData: EntityTypesServer.BaseAbility in currentAbilities do
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

            context.PublicSignals.AbilityExpired:Fire({
                Entity = entity,
                AbilityData = abilityData
            })
        end
    end

    -- Parry Stun Handling
    for entity, _, parryStunned: EntityTypesServer.ParryStunnedComponent in World:query(Tags.Creature, Components.ParryStunned) do
        local ServerTime = workspace.DistributedGameTime

        if parryStunned <= ServerTime then
            World:remove(entity, Components.ParryStunned)
        end
    end

    -- Movement Handling
    for entity, _, character: EntityTypesServer.CharacterComponent in World:query(Tags.Creature, Components.Character) do
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

return AbilitySystem :: Module
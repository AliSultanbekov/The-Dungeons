--[=[
    @class TestSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesClient = require("EntityTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AbilitySystem = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(AbilitySystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function AbilitySystem.Update(self: Module, context: EntityTypesClient.SystemModuleUpdateContext)
    local World = context.World
    local Tags = context.Tags
    local Components = context.Components
    
    for entity, _, abilityCooldowns in World:query(Tags.Alive, Components.AbilityCooldowns) do
        local Changed = false
        local ServerTime = workspace.DistributedGameTime

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

    for entity, _, currentAbility: EntityTypesClient.CurrentAbilityComponent in World:query(Tags.Alive, Components.CurrentAbility) do
        if currentAbility.IsHeld then
            continue
        end

        local ServerTime = workspace.DistributedGameTime

        if currentAbility.StartTime + currentAbility.Duration + 0.1 <= ServerTime then
            World:set(entity, Components.PreviousAbility, table.clone(currentAbility))
            World:remove(entity, Components.CurrentAbility)

            if currentAbility.AbilityName == "Block" then
                World:remove(entity, Components.Blocking)
            end
        end
    end

    for entity, _, character: EntityTypesClient.CharacterComponent in World:query(Tags.Alive, Components.Character) do
        local IsAbilityActive = World:has(entity, Components.CurrentAbility)

        if IsAbilityActive then
            character.Humanoid.WalkSpeed = 10
        else
            character.Humanoid.WalkSpeed = 16
        end
    end
end

return AbilitySystem :: Module
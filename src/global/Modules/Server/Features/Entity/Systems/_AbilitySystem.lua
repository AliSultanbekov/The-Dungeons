--[=[
    @class TestSystem
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
    for entity, _, currentAbility: EntityTypesServer.CurrentAbilityComponent in World:query(Tags.Alive, Components.CurrentAbility) do
        if currentAbility.IsHeld then
            continue
        end

        local ServerTime = workspace.DistributedGameTime

        if currentAbility.StartTime + currentAbility.Duration < ServerTime then
            World:set(entity, Components.PreviousAbility, table.clone(currentAbility))
            World:remove(entity, Components.CurrentAbility)

            if currentAbility.AbilityName == "Block" then
                World:remove(entity, Components.Blocking)
            end
        end
    end

    for entity, _, character: EntityTypesServer.CharacterComponent in World:query(Tags.Alive, Components.Character) do
        local IsAbilityActive = World:has(entity, Components.CurrentAbility)

        if IsAbilityActive then
            character.Humanoid.WalkSpeed = 10
        else
            character.Humanoid.WalkSpeed = 16
        end
    end
end

return AbilitySystem :: Module
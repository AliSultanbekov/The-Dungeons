--[=[
    @class CreatureUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local CombatConfig = require("CombatConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureUtil = {}

-- [ Types ] --
type CanDamage_Context = {
    AttackerEntity: Jecs.Entity,
    AttackedEntity: Jecs.Entity,
    World: Jecs.World,
    Tags: { [string]: Jecs.Entity },
    Components: { [string]: Jecs.Entity },
}
type GetHitType_Context = {
    AttackerEntity: Jecs.Entity,
    AttackedEntity: Jecs.Entity,
    World: Jecs.World,
    Components: { [string]: Jecs.Entity },
}
type GetCurrentAbility_Context = {
    Entity: Jecs.Entity,
    World: Jecs.World,
    Components: { [string]: Jecs.Entity },
}
type GetPreviousAbility_Context = {
    Entity: Jecs.Entity,
    World: Jecs.World,
    Components: { [string]: Jecs.Entity },
}
type IsAbilityActive_Context = {
    Entity: Jecs.Entity,
    World: Jecs.World,
    Components: { [string]: Jecs.Entity },
    AbilityName: string?,
}
type CanUseAbility_Context = {
    Entity: Jecs.Entity,
    World: Jecs.World,
    Components: { [string]: Jecs.Entity },
    AbilityData: any,
}
type CanEndAbility_Context = {
    Entity: Jecs.Entity,
    World: Jecs.World,
    Components: { [string]: Jecs.Entity },
    AbilityName: string?,
}
type ModuleData = {}
export type Module = typeof(CreatureUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureUtil.CanDamage(self: Module, context: CanDamage_Context): boolean
    local AttackerEntity = context.AttackedEntity
    local AttackedEntity = context.AttackedEntity
    local World = context.World
    local Tags = context.Tags
    local Components = context.Components

    if not World:has(AttackerEntity, Tags.Alive, Components.Health) then
        return false
    end

    local AttackedHealth = World:get(AttackedEntity, Components.Health)

    if AttackedHealth <= 0 then
        return false
    end

    if World:get(AttackerEntity, Components.Stunned) then
        return false
    end 

    return true
end

function CreatureUtil.GetHitInfo(self: Module, context: GetHitType_Context): string?
    local AttackerEntity = context.AttackedEntity
    local AttackedEntity = context.AttackedEntity
    local World = context.World
    local Components = context.Components

    if World:get(AttackedEntity, Components.Blocking) then
        local CurrentAbility = World:get(AttackedEntity, Components.CurrentAbility)

        if not CurrentAbility then
            return
        end

        local ServerTime = workspace.DistributedGameTime

        local Delta = ServerTime - CurrentAbility.StartTime

        print(Delta)
        print(ServerTime)
        print(CurrentAbility.StartTime)

        if Delta <= CombatConfig.ParryWindowTime then
            World:set(AttackerEntity, Components.ParryStunned, {
                StartTime = ServerTime,
                Duration = 0.75
            })

            return "Parried"
        end

        return "Blocked"
    end

    return "Hit"
end

function CreatureUtil.GetCurrentAbility(self: Module, context: GetCurrentAbility_Context): any
    local Entity = context.Entity
    local World = context.World
    local Components = context.Components

    if not World:has(Entity, Components.CurrentAbility) then
        return
    end

    return World:get(Entity, Components.CurrentAbility)
end

function CreatureUtil.GetPreviousAbility(self: Module, context: GetPreviousAbility_Context): any
    local Entity = context.Entity
    local World = context.World
    local Components = context.Components

    if not World:has(Entity, Components.PreviousAbility) then
        return
    end

    return World:get(Entity, Components.PreviousAbility)
end

function CreatureUtil.IsAbilityActive(self: Module, context: IsAbilityActive_Context): boolean
    local Entity = context.Entity
    local World = context.World
    local Components = context.Components

    local CurrentAbility = World:get(Entity, Components.CurrentAbility)

    if not CurrentAbility then
        return false
    end

    if context.AbilityName and CurrentAbility.AbilityName ~= context.AbilityName then
        return false
    end

    return true
end

function CreatureUtil.CanUseAbility(self: Module, context: CanUseAbility_Context)
    local Entity = context.Entity
    local World = context.World
    local Components = context.Components
    local AbilityData = context.AbilityData

    if World:has(Entity, Components.CurrentAbility) then
        return false
    end

    if World:has(Entity, Components.Stunned) then
        return false
    end

    if World:has(Entity, Components.ParryStunned) and AbilityData.AbilityName ~= "Block" then
        return false
    end
    
    return true
end

function CreatureUtil.CanEndAbility(self: Module, context: CanEndAbility_Context)
    local Entity = context.Entity
    local World = context.World
    local Components = context.Components
    local AbilityName = context.AbilityName

    local CurrentAbility = World:get(Entity, Components.CurrentAbility)

    if not CurrentAbility then
        print("22")
        return false
    end

    if AbilityName and CurrentAbility.AbilityName ~= AbilityName then
        print("333")
        return false
    end

    return true
end

return CreatureUtil :: Module
--[=[
    @class CreatureAbility
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local EntityTypesClient = require("EntityTypesClient")
local AbilityConfig = require("AbilityConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureAbility = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))

type ModuleData = {
    _EntityServiceClient: EntityServiceClient
}

export type Module = typeof(CreatureAbility) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureAbility.IsAbilityOnCooldown(self: Module, entity: Jecs.Entity, abilityName: string): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local AbilityCooldowns = World:get(entity, Components.AbilityCooldowns)

    if not AbilityCooldowns then
        return false
    end

    if AbilityCooldowns[abilityName] then
        return true
    else
        return false
    end
end

function CreatureAbility.StartAbilityCooldown(self: Module, entity: Jecs.Entity, abilityName: string)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local AbilityCooldowns = World:get(entity, Components.AbilityCooldowns)

    if not AbilityCooldowns then
        return
    end

    local AbilityData = AbilityConfig[abilityName]

    if not AbilityData or not AbilityData.CooldownDuration then
        return
    end

    local ServerTime = workspace:GetServerTimeNow()
    AbilityCooldowns[abilityName] = ServerTime + AbilityData.CooldownDuration

    World:set(entity, Components.AbilityCooldowns, AbilityCooldowns)
end

function CreatureAbility.IsAbilityActive(self: Module, entity: Jecs.Entity, abilityName: string?): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CurrentAbility = World:get(entity, Components.CurrentAbility)

    if not CurrentAbility then
        return false
    end

    if abilityName and CurrentAbility.AbilityName ~= abilityName then
        return false
    end

    return true
end

function CreatureAbility.GetCurrentAbility(self: Module, entity: Jecs.Entity): EntityTypesClient.CurrentAbilityComponent?
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    if not World:has(entity, Components.CurrentAbility) then
        return
    end

    return World:get(entity, Components.CurrentAbility)
end

function CreatureAbility.GetPreviousAbility(self: Module, entity: Jecs.Entity): EntityTypesClient.PreviousAbilityComponent?
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    if not World:has(entity, Components.PreviousAbility) then
        return
    end

    return World:get(entity, Components.PreviousAbility)
end

function CreatureAbility.UseAbility(self: Module, entity: Jecs.Entity, abilityData: EntityTypesClient.CurrentAbilityComponent): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local AbilityCooldowns = World:get(entity, Components.AbilityCooldowns)

    if not AbilityCooldowns then
        return false
    end

    if AbilityCooldowns[abilityData.AbilityName] then
        return false
    end

    if World:has(entity, Components.Stunned) or (World:has(entity, Components.ParryStunned) and abilityData.AbilityName == "Blocking") then
        return false
    end

    local CurrentAbility = World:get(entity, Components.CurrentAbility)

    if CurrentAbility then
        local CanCancelAbility = self:CancelAbility(entity, abilityData.AbilityName)

        if not CanCancelAbility then
            if not self:EndAbility(entity, abilityData.AbilityName) then
                return false
            end
        end
    end

    World:set(entity, Components.CurrentAbility, abilityData)

    if abilityData.AbilityName == "Block" then
        World:set(entity, Components.Blocking, true)
    end

    return true
end

function CreatureAbility.CancelAbility(self: Module, entity: Jecs.Entity, abilityName: string?): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CurrentAbility = World:get(entity, Components.CurrentAbility)

    if not CurrentAbility then
        return false
    end

    if abilityName and (abilityName ~= CurrentAbility.AbilityName) or (CurrentAbility.AbilityName == abilityName) then
        return false
    end

    local ServerTime = workspace:GetServerTimeNow()
    local StartTime = CurrentAbility.StartTime
    local DeltaTime = ServerTime - StartTime

    if CurrentAbility.IsHeld or (CurrentAbility.CommitTime and DeltaTime > CurrentAbility.CommitTime) then
        return false
    end

    World:remove(entity, Components.CurrentAbility)

    if CurrentAbility.AbilityName == "Block" then
        World:remove(entity, Components.Blocking)
    end

    return true
end

function CreatureAbility.EndAbility(self: Module, entity: Jecs.Entity, abilityName: string?): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CurrentAbility = World:get(entity, Components.CurrentAbility)

    if not CurrentAbility then
        return false
    end

    if abilityName and (abilityName ~= CurrentAbility.AbilityName) or (CurrentAbility.AbilityName == abilityName) then
        return false
    end

    local ServerTime = workspace:GetServerTimeNow()
    local StartTime = CurrentAbility.StartTime
    local DeltaTime = ServerTime - StartTime

    if CurrentAbility.IsHeld or (CurrentAbility.CommitTime and DeltaTime > CurrentAbility.CommitTime) then
        return false
    end

    World:set(entity, Components.PreviousAbility, table.clone(CurrentAbility))
    World:remove(entity, Components.CurrentAbility)

    if CurrentAbility.AbilityName == "Block" then
        World:remove(entity, Components.Blocking)
    end

    return true
end

function CreatureAbility.Init(self: Module, entityServiceClient: EntityServiceClient)
    self._EntityServiceClient = entityServiceClient
end

function CreatureAbility.Start(self: Module)

end

return CreatureAbility :: Module

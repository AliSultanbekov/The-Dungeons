--[=[
    @class CreatureAbility
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../CreatureTypesClient")

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local EntityTypesClient = require("EntityTypesClient")
local AbilityConfig = require("AbilityConfig")
local TimeUtil = require("TimeUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureAbility = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))

type ModuleData = {
    _EntityServiceClient: EntityServiceClient,
    _Signals: Types.PublicSignals
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

function CreatureAbility.StartAbilityCooldown(self: Module, entity: Jecs.Entity, abilityName: string, cooldownDuration: number?)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local AbilityCooldowns = World:get(entity, Components.AbilityCooldowns)

    if not AbilityCooldowns then
        return
    end

    local AbilityConfigData = AbilityConfig.Abilities[abilityName]

    local CooldownDuration = cooldownDuration or AbilityConfigData and AbilityConfigData.CooldownDuration

    if not CooldownDuration then
        return
    end

    local ServerTime = TimeUtil:GetTime()
    AbilityCooldowns[abilityName] = ServerTime + CooldownDuration

    World:set(entity, Components.AbilityCooldowns, AbilityCooldowns)
end

function CreatureAbility.IsAbilityActive(self: Module, entity: Jecs.Entity, abilityName: string?): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CurrentAbilities = World:get(entity, Components.CurrentAbilities)

    if not CurrentAbilities then
        return false
    end

    print(CurrentAbilities)

    if not abilityName and next(CurrentAbilities) ~= nil then
        return true
    else
        for _, abilityData in CurrentAbilities do
            if abilityData.AbilityName == abilityName then
                return true
            end
        end
    end

    return false
end

function CreatureAbility.GetCurrentAbility(self: Module, entity: Jecs.Entity, abilityName: string): (EntityTypesClient.BaseAbility | EntityTypesClient.ComboAbility)?
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CurrentAbilities = World:get(entity, Components.CurrentAbilities)

    if not CurrentAbilities then
        return
    end

    for _, abilityData in CurrentAbilities do
        if abilityData.AbilityName == abilityName then
            return abilityData
        end
    end

    return
end

function CreatureAbility.GetPreviousAbility(self: Module, entity: Jecs.Entity, abilityName: string): (EntityTypesClient.BaseAbility | EntityTypesClient.ComboAbility)?
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local PreviousAbilities = World:get(entity, Components.PreviousAbilities)

    if not PreviousAbilities then
        return
    end

    for _, abilityData in PreviousAbilities do
        if abilityData.AbilityName == abilityName then
            return abilityData
        end
    end

    return
end

function CreatureAbility.UseAbility(self: Module, entity: Jecs.Entity, abilityData: EntityTypesClient.BaseAbility): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components =self._EntityServiceClient:GetComponents()

    local AbilityCooldowns = World:get(entity, Components.AbilityCooldowns)

    if not AbilityCooldowns or AbilityCooldowns[abilityData.AbilityName] then
        return false
    end

    local NewAbilityConfigData = AbilityConfig.Abilities[abilityData.AbilityName]

    if not NewAbilityConfigData then
        return false
    end

    if World:has(entity, Components.Stunned) or (World:has(entity, Components.ParryStunned) and not NewAbilityConfigData.UsableOnParryStun) then
        return false
    end

    local CurrentAbilities = World:get(entity, Components.CurrentAbilities)

    if not CurrentAbilities then
        return false
    end

    if CurrentAbilities[abilityData.AbilityName] then
        return false
    end

    if next(CurrentAbilities) ~= nil then
        local NewAbilityCategory = NewAbilityConfigData.Category or "None"
        local InterruptRules = AbilityConfig.InterruptRules
        local ConflictRules = AbilityConfig.ConflictRules

        -- Check ability conflictions --
        local ConflictedCategories = ConflictRules[NewAbilityCategory] or {}
        local InterruptableCategories = InterruptRules[NewAbilityCategory] or {}

        local AbilitiesToInterrupt = {}

        for _, currentAbilityData in CurrentAbilities do
            local CurrentAbilityConfigData = AbilityConfig.Abilities[currentAbilityData.AbilityName]

            if not CurrentAbilityConfigData then
                continue
            end

            local CurrentAbilityCategory = CurrentAbilityConfigData.Category

            if not CurrentAbilityCategory then
                continue
            end
            
            -- Ability Conflicts
            for _, conflictedCategory in ConflictedCategories do
                if CurrentAbilityCategory == conflictedCategory then
                    return false
                end
            end

            -- Ability Interruptions
            for _, interruptableCategory in InterruptableCategories do
                if interruptableCategory == CurrentAbilityCategory then
                    table.insert(AbilitiesToInterrupt, currentAbilityData)
                end
            end
        end

        for _, interruptableAbilityData in AbilitiesToInterrupt do
            if not self:InterruptAbility(entity, interruptableAbilityData.AbilityName) then
                return false
            end
        end
    end

    CurrentAbilities[abilityData.AbilityName] = abilityData

    World:set(entity, Components.CurrentAbilities, CurrentAbilities)

    local AbilityConfigData = AbilityConfig.Abilities[abilityData.AbilityName]
    local AbilityComponents = AbilityConfigData.Components

    if AbilityComponents then
        for _, componentName in AbilityComponents do
            World:set(entity, Components[componentName], true)
        end
    end

    return true
end

function CreatureAbility.InterruptAbility(self: Module, entity: Jecs.Entity, currentAbilityName: string): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components =self._EntityServiceClient:GetComponents()

    local CurrentAbilities = World:get(entity, Components.CurrentAbilities)

    if not CurrentAbilities then
        return false
    end

    local CurrentAbility = CurrentAbilities[currentAbilityName]

    if not CurrentAbility then
        return false
    end

    local ServerTime = TimeUtil:GetTime()
    local StartTime = CurrentAbility.StartTime
    local CommitTime = CurrentAbility.CommitTime

    if CurrentAbility.IsHeld then
        return self:EndAbility(entity, currentAbilityName)
    else
        if CommitTime then
            if StartTime + CommitTime > ServerTime then
                return false
            else
                return self:EndAbility(entity, currentAbilityName)
            end
        else
            return self:EndAbility(entity, currentAbilityName)
        end
    end
end

function CreatureAbility.CancelAbility(self: Module, entity: Jecs.Entity, abilityName: string): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CurrentAbilities = World:get(entity, Components.CurrentAbilities)
    local PreviousAbilities = World:get(entity, Components.PreviousAbilities)

    if not CurrentAbilities or not PreviousAbilities then
        return false
    end

    local CurrentAbility = CurrentAbilities[abilityName]

    if not CurrentAbility then
        return false
    end

    local ServerTime = TimeUtil:GetTime()
    local StartTime = CurrentAbility.StartTime
    local DeltaTime = ServerTime - StartTime

    if CurrentAbility.CommitTime and DeltaTime > CurrentAbility.CommitTime then
        if not CurrentAbility.IsHeld then
            return false
        end
    end

    CurrentAbilities[abilityName] = nil

    World:set(entity, Components.CurrentAbilities, CurrentAbilities)

    local AbilityConfigData = AbilityConfig.Abilities[CurrentAbility.AbilityName]
    local AbilityComponents = AbilityConfigData.Components

    if AbilityComponents then
        for _, componentName in AbilityComponents do
            World:remove(entity, Components[componentName])
        end
    end

    return true
end

function CreatureAbility.EndAbility(self: Module, entity: Jecs.Entity, abilityName: string): boolean
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local CurrentAbilities = World:get(entity, Components.CurrentAbilities)
    local PreviousAbilities = World:get(entity, Components.PreviousAbilities)

    if not CurrentAbilities or not PreviousAbilities then
        return false
    end

    local CurrentAbility = CurrentAbilities[abilityName]

    if not CurrentAbility then
        return false
    end

    local ServerTime = TimeUtil:GetTime()
    local StartTime = CurrentAbility.StartTime
    local DeltaTime = ServerTime - StartTime

    local commitTime = CurrentAbility.CommitTime
    if commitTime and DeltaTime <= commitTime then
        if not CurrentAbility.IsHeld then
            warn(string.format(
                "[CreatureAbility] EndAbility rejected: %s released before commit window (%.2fs < %.2fs required) | ServerTime=%.2f StartTime=%.2f",
                abilityName,
                DeltaTime,
                commitTime,
                ServerTime,
                StartTime
            ))
            return false
        end
    end

    PreviousAbilities[abilityName] = table.clone(CurrentAbility)
    CurrentAbilities[abilityName] = nil

    World:set(entity, Components.PreviousAbilities, PreviousAbilities)
    World:set(entity, Components.CurrentAbilities, CurrentAbilities)

    local AbilityConfigData = AbilityConfig.Abilities[CurrentAbility.AbilityName]
    local AbilityComponents = AbilityConfigData.Components

    if AbilityComponents then
        for _, componentName in AbilityComponents do
            World:remove(entity, Components[componentName])
        end
    end

    return true
end

function CreatureAbility.Init(self: Module, context: Types.Init_Context)
    self._EntityServiceClient = context.EntityServiceClient
    self._Signals = context.Signals
end

function CreatureAbility.Start(self: Module)
    local World = self._EntityServiceClient:GetWorld()
    local Tags = self._EntityServiceClient:GetTags()
    local Components = self._EntityServiceClient:GetComponents()

    self._EntityServiceClient.PublicSignals.AbilityExpired:Connect(function(packet: EntityTypesClient.AbilityExpiredSignalPacket)
        if not World:has(packet.Entity, Tags.Creature) then
            return
        end

        local Character = World:get(packet.Entity, Components.Character)

        if not Character then
            return
        end

        self._Signals.AbilityExpired:Fire({
            Character = Character.Character,
            AbilityData = packet.AbilityData
        })
    end)
end

return CreatureAbility :: Module

--[=[
    @class EntityTypesClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local EntityTypesShared = require("EntityTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --

-- Re-export shared types
export type NameComponent = EntityTypesShared.NameComponent
export type StatsComponent = EntityTypesShared.StatsComponent
export type CharacterComponent = EntityTypesShared.CharacterComponent
export type HealthComponent = EntityTypesShared.HealthComponent
export type EtherComponent = EntityTypesShared.EtherComponent
export type AbilityCooldownsComponent = EntityTypesShared.AbilityCooldownsComponent
export type InCombatComponent = EntityTypesShared.InCombatComponent
export type BlockingComponent = EntityTypesShared.BlockingComponent
export type DodgingComponent = EntityTypesShared.DodgingComponent
export type ParryStunnedComponent = EntityTypesShared.ParryStunnedComponent
export type StunnedComponent = EntityTypesShared.StunnedComponent
export type CurrentAbilityComponent = EntityTypesShared.CurrentAbilityComponent
export type PreviousAbilityComponent = EntityTypesShared.PreviousAbilityComponent
export type EntityCreatedSignalPacket = EntityTypesShared.EntityCreatedSignalPacket
export type EntityDeletedSignalPacket = EntityTypesShared.EntityDeletedSignalPacket

-- Client Tags (same as shared for now)
export type Tags = EntityTypesShared.Tags

-- Client Components (same as shared for now)
export type Components = EntityTypesShared.Components

-- System Types
export type SystemModuleUpdateContext = {
    World: Jecs.World,
    Tags: Tags,
    Components: Components,
    Dt: number,
}

export type SystemModule = {
    Update: (self: SystemModule, context: SystemModuleUpdateContext) -> (),
}

-- Client-specific Types
export type EntityCreationData = {
    Tags: { string },
    Components: { [string]: any },
}

export type EntityDeletionData = {
    Entity: Jecs.Entity,
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil

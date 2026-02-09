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
local AnimationClass = require("AnimationClass")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --

-- VelocityTypes
export type LinearVelocityData = {
    VelocityType: "LinearVelocity",
    StartTime: number,
    Mode: Enum.VelocityConstraintMode,
    PlaneVelocity: Vector2,
    PrimaryTangentAxis: Vector3,
    SecondaryTangentAxis: Vector3,
    StartSpeed: number,
    Duration: number,
    Curve: string,
}

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
export type BaseAbility = EntityTypesShared.BaseAbility
export type ComboAbility = EntityTypesShared.ComboAbility
export type CurrentAbilities = EntityTypesShared.CurrentAbilities
export type PreviousAbilities = EntityTypesShared.PreviousAbilities
export type AnimationObjectComponent = AnimationClass.Object
export type VelocityComponent = LinearVelocityData

export type EntityCreatedSignalPacket = EntityTypesShared.EntityCreatedSignalPacket
export type EntityDeletedSignalPacket = EntityTypesShared.EntityDeletedSignalPacket
export type AbilityExpiredSignalPacket = EntityTypesShared.AbilityExpiredSignalPacket

-- Client Tags (same as shared for now)
export type Tags = EntityTypesShared.Tags

-- Client Components (same as shared for now)
export type Components = EntityTypesShared.Components & {
    AnimationObject: Jecs.Entity<AnimationObjectComponent>,
    Velocity: Jecs.Entity<VelocityComponent>
}

-- System Types
export type PublicSignals = {
    EntityCreated: Signal.Signal<EntityCreatedSignalPacket>,
    EntityDeleted: Signal.Signal<EntityDeletedSignalPacket>,
    AbilityExpired: Signal.Signal<AbilityExpiredSignalPacket>,
}

export type SystemModuleUpdateContext = {
    World: Jecs.World,
    Tags: Tags,
    Components: Components,
    Dt: number,
    PublicSignals: PublicSignals
}

export type SystemModule = {
    Update: (self: SystemModule, context: SystemModuleUpdateContext) -> (),
}

-- Client-specific Types
export type EntityCreationData = {
    Tags: { [string]: boolean },
    Components: { [string]: any },
}

export type EntityDeletionData = {
    Entity: Jecs.Entity,
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil

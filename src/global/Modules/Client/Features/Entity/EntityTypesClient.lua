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
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --

-- VelocityTypes
export type LinearVelocityData = {
    Mode: "Plane",
    Instance: LinearVelocity,
    Attachment0: Attachment,
    StartTime: number,
    StartSpeed: number,
    Duration: number,
    GetDirection: () -> Vector2,
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
export type VelocityComponent = LinearVelocityData

export type EntityCreatedSignalPacket = EntityTypesShared.EntityCreatedSignalPacket
export type EntityDeletedSignalPacket = EntityTypesShared.EntityDeletedSignalPacket
export type AbilityExpiredSignalPacket = EntityTypesShared.AbilityExpiredSignalPacket

-- Client Tags (same as shared for now)
export type Tags = EntityTypesShared.Tags

-- Client Components (same as shared for now)
export type Components = EntityTypesShared.Components & {
    Velocity: Jecs.Entity<VelocityComponent>
}

-- System Types
export type PublicSignals = {
    EntityCreated: Signal.Signal<EntityCreatedSignalPacket>,
    EntityDeleted: Signal.Signal<EntityDeletedSignalPacket>,
    AbilityExpired: Signal.Signal<AbilityExpiredSignalPacket>,
}

export type SystemModule_Init_Context = {
    World: Jecs.World,
    Tags: Tags,
    Components: Components,
    Signals: PublicSignals,
}

export type SystemModule = {
    Init: (self: SystemModule, context: SystemModule_Init_Context) -> (),
    Update: (self: SystemModule, dt: number) -> (),
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

--[=[
    @class EntityTypesServer
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

-- Re-export shared types
export type BaseAbility = EntityTypesShared.BaseAbility
export type ComboAbility = EntityTypesShared.ComboAbility
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
export type CurrentAbilities = EntityTypesShared.CurrentAbilities
export type PreviousAbilities = EntityTypesShared.PreviousAbilities
export type EntityCreatedSignalPacket = EntityTypesShared.EntityCreatedSignalPacket
export type EntityDeletedSignalPacket = EntityTypesShared.EntityDeletedSignalPacket
export type AbilityExpiredSignalPacket = EntityTypesShared.AbilityExpiredSignalPacket

-- Server-specific Tags
export type Tags = EntityTypesShared.Tags & {
    ReplicatedEntity: Jecs.Entity,
    ReplicatedComponent: Jecs.Entity,
}

-- Server-specific Component Types
export type PrefabComponent = Model
export type HealthBuffComponent = number
export type DamageBuffComponent = {
    StartTime: number,
    Duration: number,
}
export type SpeedBuffComponent = number
export type MitigationBuffComponent = number
export type HealthDebuffComponent = number
export type DamageDebuffComponent = number
export type SpeedDebuffComponent = number
export type MitigationDebuffComponent = number
export type OverTimeEffectComponent = {
    StartTime: number,
    Duration: number,
    TotalAmount: number,
}

-- Server Components (shared + server-specific)
export type Components = EntityTypesShared.Components & {
    Prefab: Jecs.Entity<PrefabComponent>,
    HealthBuff: Jecs.Entity<HealthBuffComponent>,
    DamageBuff: Jecs.Entity<DamageBuffComponent>,
    SpeedBuff: Jecs.Entity<SpeedBuffComponent>,
    MitigationBuff: Jecs.Entity<MitigationBuffComponent>,
    HealthDebuff: Jecs.Entity<HealthDebuffComponent>,
    DamageDebuff: Jecs.Entity<DamageDebuffComponent>,
    SpeedDebuff: Jecs.Entity<SpeedDebuffComponent>,
    MitigationDebuff: Jecs.Entity<MitigationDebuffComponent>,
    DamageOverTimeEffect: Jecs.Entity<OverTimeEffectComponent>,
    HealOverTimeEffect: Jecs.Entity<OverTimeEffectComponent>,
    InvinsibilityEffect: Jecs.Entity<OverTimeEffectComponent>,
    ShieldEffect: Jecs.Entity<OverTimeEffectComponent>,
    InvulnerabilityEffect: Jecs.Entity<OverTimeEffectComponent>,
    LifestealBuff: Jecs.Entity<OverTimeEffectComponent>,
    StunEffect: Jecs.Entity<OverTimeEffectComponent>,
    RootEffect: Jecs.Entity<OverTimeEffectComponent>,
    SilenceEffect: Jecs.Entity<OverTimeEffectComponent>,
    FearEffect: Jecs.Entity<OverTimeEffectComponent>,
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
    PublicSignals: PublicSignals,
}

export type SystemModule = {
    Update: (self: SystemModule, context: SystemModuleUpdateContext) -> (),
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil

--[=[
    @class EntityTypesServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --
local StatTypes = require("StatsTypes")

export type Tags = {
    Alive: Jecs.Entity,
    Player: Jecs.Entity,
    NPC: Jecs.Entity,
    ReplicatedEntity: Jecs.Entity,
    ReplicatedComponent: Jecs.Entity,
}
export type NameComponent = string
export type StatsComponent = StatTypes.PlayerStats
export type CharacterComponent = {
    Character: Model,
    Humanoid: Humanoid,
}
export type PrefabComponent = Model
export type AbilityCooldownsComponent = {
    [string]: number
}
export type InCombatComponent = {
    Duration: number,
    CurrentDuration: number,
}
export type HealthComponent = number
export type EtherComponent = number
export type BlockingComponent = boolean
export type DodgingComponent = boolean
export type ParryStunned = boolean
export type StunnedComponent = boolean
export type CurrentAbilityComponent = {
    AbilityName: string,
    StartTime: number,
    Duration: number,
    IsHeld: boolean?,
    [string]: any,
}
export type PreviousAbilityComponent = CurrentAbilityComponent
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
export type Components = {
    Name: Jecs.Entity<NameComponent>,
    Stats: Jecs.Entity<StatsComponent>,
    Character: Jecs.Entity<CharacterComponent>,
    Prefab: Jecs.Entity<PrefabComponent>,
    Health: Jecs.Entity<HealthComponent>,
    Ether: Jecs.Entity<EtherComponent>,
    AbilityCooldowns: Jecs.Entity<AbilityCooldownsComponent>,
    InCombat: Jecs.Entity<InCombatComponent>,
    Blocking: Jecs.Entity<BlockingComponent>,
    Dodging: Jecs.Entity<DodgingComponent>,
    Stunned: Jecs.Entity<StunnedComponent>,
    ParryStunned: Jecs.Entity<ParryStunned>,
    CurrentAbility: Jecs.Entity<CurrentAbilityComponent>,
    PreviousAbility: Jecs.Entity<PreviousAbilityComponent>,
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
export type SystemModuleUpdateContext = {
    World: Jecs.World,
    Tags: Tags,
    Components: Components,
    Dt: number,
}
export type SystemModule = {
    Update: (self: SystemModule, context: SystemModuleUpdateContext) -> ()
}
export type EntityCreatedSignalPacket = {
    Entity: Jecs.Entity,
    Tags: { string },
    Components: { [string]: any },
    Replicated: boolean?,
}

export type EntityDeletedSignalPacket = {
    Entity: Jecs.Entity,
    Components: { [string]: any },
    Replicated: boolean?,
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil
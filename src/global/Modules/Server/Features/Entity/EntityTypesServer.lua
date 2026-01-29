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
export type InCombatComponent = {
    Duration: number,
    CurrentDuration: number,
}
export type HealthComponent = number
export type EtherComponent = number
export type BlockingComponent = boolean
export type DodgingComponent = boolean
export type StunnedComponent = boolean
export type CurrentAbilityComponent = {
    AbilityName: string,
    StartTime: number,
    Duration: number,
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
    Name: Jecs.Id<NameComponent>,
    Stats: Jecs.Id<StatsComponent>,
    Character: Jecs.Id<CharacterComponent>,
    Prefab: Jecs.Id<PrefabComponent>,

    Health: Jecs.Id<HealthComponent>,
    Ether: Jecs.Id<EtherComponent>,

    InCombat: Jecs.Id<InCombatComponent>,

    Blocking: Jecs.Id<BlockingComponent>,
    Dodging: Jecs.Id<DodgingComponent>,
    Stunned: Jecs.Id<StunnedComponent>,
    CurrentAbility: Jecs.Id<CurrentAbilityComponent>,
    PreviousAbility: Jecs.Id<PreviousAbilityComponent>,

    HealthBuff: Jecs.Id<HealthBuffComponent>,
    DamageBuff: Jecs.Id<DamageBuffComponent>,
    SpeedBuff: Jecs.Id<SpeedBuffComponent>,
    MitigationBuff: Jecs.Id<MitigationBuffComponent>,

    HealthDebuff: Jecs.Id<HealthDebuffComponent>,
    DamageDebuff: Jecs.Id<DamageDebuffComponent>,
    SpeedDebuff: Jecs.Id<SpeedDebuffComponent>,
    MitigationDebuff: Jecs.Id<MitigationDebuffComponent>,

    DamageOverTimeEffect: Jecs.Id<OverTimeEffectComponent>,
    HealOverTimeEffect: Jecs.Id<OverTimeEffectComponent>,
    InvinsibilityEffect: Jecs.Id<OverTimeEffectComponent>,
    ShieldEffect: Jecs.Id<OverTimeEffectComponent>,
    InvulnerabilityEffect: Jecs.Id<OverTimeEffectComponent>,
    LifestealBuff: Jecs.Id<OverTimeEffectComponent>,

    StunEffect: Jecs.Id<OverTimeEffectComponent>,
    RootEffect: Jecs.Id<OverTimeEffectComponent>,
    SilenceEffect: Jecs.Id<OverTimeEffectComponent>,
    FearEffect: Jecs.Id<OverTimeEffectComponent>,
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
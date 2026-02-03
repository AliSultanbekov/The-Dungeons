--[=[
    @class EntityTypesShared
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local StatsTypes = require("StatsTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --

-- Remote Packets
export type EntityUpdatedRemotePacket = {
    Action: "Added",
    Data: {
        Entity: Jecs.Entity,
        ComponentName: string,
        Value: any,
    },
} | {
    Action: "Removed",
    Data: {
        Entity: Jecs.Entity,
        ComponentName: string,
    },
} | {
    Action: "Updated",
    Data: {
        Entity: Jecs.Entity,
        ComponentName: string,
        Value: any,
    },
}

export type EntityCreatedRemotePacket = {
    Entity: Jecs.Entity,
    Tags: { string },
    Components: { [string]: any },
}

export type EntityDeletedRemotePacket = {
    Entity: Jecs.Entity,
}

export type EntitySyncRemotePacket = {
    {
        Entity: Jecs.Entity,
        Tags: { string },
        Components: { [string]: any },
    }
}

-- Tags
export type Tags = {
    Alive: Jecs.Entity,
    Player: Jecs.Entity,
    NPC: Jecs.Entity,
}

-- Component Types
export type NameComponent = string
export type StatsComponent = StatsTypes.PlayerStats
export type CharacterComponent = {
    Character: Model,
    Humanoid: Humanoid,
}
export type HealthComponent = number
export type EtherComponent = number
export type AbilityCooldownsComponent = {
    [string]: number,
}
export type InCombatComponent = {
    Duration: number,
    CurrentDuration: number,
}
export type BlockingComponent = boolean
export type DodgingComponent = boolean
export type ParryStunnedComponent = {
    StartTime: number,
    Duration: number,
}
export type StunnedComponent = boolean
export type BaseAbilityComponent = {
    AbilityName: string,
    StartTime: number,
    Duration: number,
    CommitTime: number?,
    IsHeld: boolean?,
}
export type ComboAbilityComponent = {
    AbilityName: string,
    StartTime: number,
    Duration: number,
    Combo: number,
    CommitTime: number?,
    IsHeld: boolean?,
}

-- Components Map
export type Components = {
    Name: Jecs.Entity<NameComponent>,
    Stats: Jecs.Entity<StatsComponent>,
    Character: Jecs.Entity<CharacterComponent>,
    Health: Jecs.Entity<HealthComponent>,
    Ether: Jecs.Entity<EtherComponent>,
    AbilityCooldowns: Jecs.Entity<AbilityCooldownsComponent>,
    InCombat: Jecs.Entity<InCombatComponent>,
    Blocking: Jecs.Entity<BlockingComponent>,
    Dodging: Jecs.Entity<DodgingComponent>,
    ParryStunned: Jecs.Entity<ParryStunnedComponent>,
    Stunned: Jecs.Entity<StunnedComponent>,
    CurrentAbility: Jecs.Entity<BaseAbilityComponent>,
    PreviousAbility: Jecs.Entity<BaseAbilityComponent>,
}

-- Signal Packets
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

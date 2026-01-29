--[=[
    @class EntityTypesClient
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
local StatsTypes = require("StatsTypes")

export type Tags = {
    Alive: Jecs.Entity,
    Player: Jecs.Entity,
    NPC: Jecs.Entity,
}

export type NameComponent = string
export type StatsComponent = StatsTypes.PlayerStats
export type CharacterComponent = {
    Character: Model,
    Humanoid: Humanoid,
}
export type HealthComponent = number
export type EtherComponent = number
export type InCombatComponent = {
    Duration: number,
    CurrentDuration: number,
}
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

export type Components = {
    Name: Jecs.Id<NameComponent>,
    Stats: Jecs.Id<StatsComponent>,
    Character: Jecs.Id<CharacterComponent>,
    Health: Jecs.Id<HealthComponent>,
    Ether: Jecs.Id<EtherComponent>,
    InCombat: Jecs.Id<InCombatComponent>,
    Blocking: Jecs.Id<BlockingComponent>,
    Dodging: Jecs.Id<DodgingComponent>,
    Stunned: Jecs.Id<StunnedComponent>,
    CurrentAbility: Jecs.Id<CurrentAbilityComponent>,
    PreviousAbility: Jecs.Id<PreviousAbilityComponent>,
}

export type SystemModuleUpdateContext = {
    World: Jecs.World,
    Tags: Tags,
    Components: Components,
    Dt: number,
}

export type SystemModule = {
    Update: (self: SystemModule, context: SystemModuleUpdateContext) -> (),
}

export type EntityCreationData = {
    Tags: { string },
    Components: { [string]: any },
}

export type EntityDeletionData = {
    Entity: Jecs.Entity,
}

export type EntityCreatedSignalPacket = {
    Entity: Jecs.Entity,
    Tags: { string },
    Components: { [string]: any },
}

export type EntityDeletedSignalPacket = {
    Entity: Jecs.Entity,
    Components: { [string]: any },
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil

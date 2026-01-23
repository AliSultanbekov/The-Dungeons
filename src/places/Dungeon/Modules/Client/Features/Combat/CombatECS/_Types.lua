--[=[
    @class Types
]=]

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --
export type SystemContext = {
    World: Jecs.World,
    Tags: Tags,
    Components: Components,
    Dt: number,
}

export type Tags = {
    Alive: Jecs.Entity,
    Player: Jecs.Entity,
    NPC: Jecs.Entity,
    Replicated: Jecs.Entity,
}

export type PlayerDataComponent = {
    Player: Player,
    Character: Model,
    Humanoid: Humanoid,
}

export type NPCDataComponent = {
    Character: Model,
    Humanoid: Humanoid,
}

export type HealthComponent = number
export type EtherComponent = number
export type BlockingComponent = {StartTime: number}
export type DodgingComponent = any
export type StunnedComponent = any
export type CurrentAbilityComponent = any
export type PreviousAbilityComponent = any

export type Components = {
    -- Shared
    PlayerData: Jecs.Id<PlayerDataComponent>,
    NPCData: Jecs.Id<NPCDataComponent>,
    Health: Jecs.Id<HealthComponent>,
    Ether: Jecs.Id<EtherComponent>,
    Blocking: Jecs.Id<BlockingComponent>,
    Dodging: Jecs.Id<DodgingComponent>,
    Stunned: Jecs.Id<StunnedComponent>,
    CurrentAbility: Jecs.Id<CurrentAbilityComponent>,
    PreviousAbility: Jecs.Id<CurrentAbilityComponent>,

    -- Private
}
-- [ Private Functions ] --

-- [ Public Functions ] --

return nil
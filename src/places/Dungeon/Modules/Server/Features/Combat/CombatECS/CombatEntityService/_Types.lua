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


export type Tags = {
    Alive: Jecs.Entity,

    Player: Jecs.Entity,
    NPC: Jecs.Entity
}

export type PlayerDataComponent = {
    Player: Player,
    Character: Model 
}
export type NPCDataComponent = {Type: string}
export type HealthComponent = number
export type EtherComponent = number
export type PositionComponent = Vector3
export type BlockingComponent = {StartTime: number}
export type DodgingComponent = any
export type StunnedComponent = any

export type Components = {
    -- Identity
    PlayerData: Jecs.Id<PlayerDataComponent>,
    NPCData: Jecs.Id<NPCDataComponent>,

    -- Permanent stats
    Health: Jecs.Id<HealthComponent>,
    Ether: Jecs.Id<EtherComponent>,
    Position: Jecs.Id<PositionComponent>,

    -- Combat states
    Blocking: Jecs.Id<BlockingComponent>,
    Dodging: Jecs.Id<DodgingComponent>,
    Stunned: Jecs.Id<StunnedComponent>
}

export type SystemContext = {
    World: Jecs.World,
    Tags: Tags,
    Components: Components,
    Dt: number,
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil
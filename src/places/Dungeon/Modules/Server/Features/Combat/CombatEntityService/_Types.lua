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

type PlayerDataComponent = {
    Player: Player,
    Character: Model,
}

type NPCDataComponent = {
    Type: "CoolOne"
}

export type Tags = {
    Player: Jecs.Entity,
    NPC: Jecs.Entity
}

export type Components = {
    -- Identity
    PlayerData: Jecs.Id<PlayerDataComponent>,
    NPCData: Jecs.Id<NPCDataComponent>,

    -- Permanent stats
    Health: Jecs.Id<number>,
    Positon: Jecs.Id<Vector3>,

    -- Combat states
    Blocking: Jecs.Id<{
        StartTime: number
    }>,
    Parrying: Jecs.Id<any>,
    Dodging: Jecs.Id<any>,
    Stunned: Jecs.Id<any>,
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
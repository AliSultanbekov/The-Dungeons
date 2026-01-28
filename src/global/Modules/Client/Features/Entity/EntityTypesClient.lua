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
export type Tags = {
    Alive: Jecs.Entity,
    Player: Jecs.Entity,
    NPC: Jecs.Entity,
    Replicated: Jecs.Entity,
}

export type CharacterComponent = {
    Character: Model,
    Humanoid: Humanoid,
}

export type PlayerComponent = {
    Player: Player,
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
    [string]: number,
}

export type PreviousAbilityComponent = CurrentAbilityComponent

export type Components = {
    Character: Jecs.Id<CharacterComponent>,
    Player: Jecs.Id<PlayerComponent>,

    Health: Jecs.Id<HealthComponent>,
    Ether: Jecs.Id<EtherComponent>,

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

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil

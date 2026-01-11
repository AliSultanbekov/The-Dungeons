-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Activate_Context = {
    Mode: Mode,
    Attacker: Model,
}

export type AbilityObject = {
    Activate: (self: AbilityObject, Activate_Context) -> ClientAbilityData
}

export type AbilityModule = {
    __index: AbilityModule,
    new: (config: any) -> AbilityObject,
}

export type Mode = string

export type Hits = { Model }

export type ClientAbilityData = {
    Hits: Hits
}

return nil
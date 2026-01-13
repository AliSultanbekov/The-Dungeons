-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type ClientActivate_Context = {
    Mode: Mode,
    Attacker: Model,
}

export type ServerActivate_Context = {
    Attacker: Model,
    Hits: Hits
}

export type ClientAbilityObject = {
    Activate: (self: ClientAbilityObject, ClientActivate_Context) -> ClientAbilityData
}

export type ClientAbilityModule = {
    __index: ClientAbilityModule,
    new: (config: any) -> ClientAbilityObject,
}

export type ServerAbilityObject = {
    Activate: (self: ServerAbilityObject, ServerActivate_Context) -> any
}

export type ServerAbilityModule = {
    __index: ClientAbilityModule,
    new: (config: any) -> ServerAbilityObject,
}

export type Mode = string

export type Hits = { Model }

export type ClientAbilityData = {
    Hits: Hits
}

return nil
-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type ClientAbilityObject = {
    AbilityName: string,
    Use: (self: ClientAbilityObject, context: {[any]: any}) -> (),
    Apply: (self: ClientAbilityObject, context: {[any]: any}) -> (),
}

export type ClientAbilityModule = {
    _index: ClientAbilityModule,
    new: (...any) -> ClientAbilityObject,
    AbilityName: string,
}

export type ServerAbilityObject = {
    AbilityName: string,
    Use: (self: ServerAbilityObject, context: {[any]: any}) -> (),
    Apply: (self: ServerAbilityObject, context: {[any]: any}) -> (),
}

export type ServerAbilityModule = {
    _index: ServerAbilityModule,
    new: (...any) -> ServerAbilityObject,
    AbilityName: string,
}

return nil
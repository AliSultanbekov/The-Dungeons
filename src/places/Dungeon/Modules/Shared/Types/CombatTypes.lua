-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type ClientAbilityObject = {
    Use: (self: ClientAbilityObject, context: {[any]: any}) -> (),
    Apply: (self: ClientAbilityObject, context: {[any]: any}) -> (),
}

export type ClientAbilityModule = {
    _index: ClientAbilityModule,
    new: (...any) -> ClientAbilityObject,
}

export type ServerAbilityObject = {
    Use: (self: ServerAbilityObject, context: {[any]: any}) -> (),
    Apply: (self: ServerAbilityObject, context: {[any]: any}) -> (),
}

export type ServerAbilityModule = {
    _index: ServerAbilityModule,
    new: (...any) -> ServerAbilityObject,
}

return nil
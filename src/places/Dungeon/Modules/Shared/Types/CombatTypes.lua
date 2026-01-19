-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Mode = "FromClient" | "FromServer"

export type ClientAbilityObject = {
    AbilityName: string,
    Use: (self: ClientAbilityObject, context: {[any]: any}) -> (),
    End: (self: ServerAbilityObject, context: {[any]: any}) -> (),
    Hit: (self: ClientAbilityObject, context: {[any]: any}) -> (),
    IsActive: (self: ClientAbilityObject) -> boolean,
}

export type ClientAbilityModule = {
    _index: ClientAbilityModule,
    new: (...any) -> ClientAbilityObject,
    AbilityName: string,
}

export type ServerAbilityObject = {
    AbilityName: string,
    Use: (self: ServerAbilityObject, context: {[any]: any}) -> (),
    End: (self: ServerAbilityObject, context: {[any]: any}) -> (),
    Hit: (self: ServerAbilityObject, context: {[any]: any}) -> (),
    IsActive: (self: ServerAbilityObject) -> boolean,
}

export type ServerAbilityModule = {
    _index: ServerAbilityModule,
    new: (...any) -> ServerAbilityObject,
    AbilityName: string,
}


export type UseAbilityRemotePacket = {}
export type EndAbilityRemotePacket = {}
export type HitAbilityRemotePacket = {}

export type AbilityUsedRemotePacket = {}
export type AbilityEndedRemotePacket = {}
export type AbilityHitRemotePacket = {}

return nil
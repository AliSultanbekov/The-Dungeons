-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")

-- [ Types ] --
export type Mode = "FromClient" | "FromServer" | "FromECS"

export type BaseNewContext = {
    [string]: any,
}

export type Context = { [string]: any }

export type AbilityObject = {
    AbilityName: string,
    Use: (self: AbilityObject, context: Context) -> (),
    End: (self: AbilityObject, context: Context) -> (),
    Hit: (self: AbilityObject, context: Context) -> (),
    UpdateState: (self: AbilityObject, context: Context) -> (),
    GetState: (self: AbilityObject) -> Context,
    IsActive: (self: AbilityObject) -> boolean,
}

export type ClientAbilityObject = {
    AbilityName: string,
    Use: (self: ClientAbilityObject, context: Context) -> (),
    End: (self: ClientAbilityObject, context: Context) -> (),
    Hit: (self: ClientAbilityObject, context: Context) -> (),
}

export type AbilityModule = {
    _index: AbilityModule,
    new: (...any) -> AbilityObject,
    AbilityName: string,
}

export type UseAbilityRemotePacket = Context?
export type EndAbilityRemotePacket = Context?
export type HitAbilityRemotePacket = Context?

export type AbilityUsedRemotePacket = Context?
export type AbilityEndedRemotePacket = Context?
export type AbilityHitRemotePacket = Context?
export type AbilityStateUpdatedRemotePacket = Context?
export type EntityStateUpdatedRemotePacket = {
    Action: "Added",
    Data: {
        Entity: Jecs.Entity,
        Component: Jecs.Entity,
        Value: any
    },
} | {
    Action: "Removed",
    Data: {
        Entity: Jecs.Entity,
        Component: Jecs.Entity,
    },
} | {
    Action: "Updated",
    Data: {
        Entity: Jecs.Entity,
        Component: Jecs.Entity,
        Value: any
    },
}

return nil
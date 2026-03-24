--[=[
    @class Types
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local EntityServiceClient = require("EntityServiceClient")
local Signal = require("Signal")
local EntityTypesClient = require("EntityTypesClient")
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --
export type CreatureCreatedSignalPacket = {
    Entity: Jecs.Entity,
    Character: Model,
}

export type CreatureDeletedSignalPacket = {
    Entity: Jecs.Entity,
    Character: Model,
}

export type AbilityExpiredSignalPacket = {
    Character: Model,
    AbilityData: EntityTypesClient.BaseAbility
}

export type Init_Context = {
    EntityServiceClient: EntityServiceClient.Module, 
    Signals: PublicSignals
}

export type PublicSignals = {
    CreatureCreated: Signal.Signal<CreatureCreatedSignalPacket>,
    CreatureDeleted: Signal.Signal<CreatureDeletedSignalPacket>,
    AbilityExpired: Signal.Signal<AbilityExpiredSignalPacket>,
}

export type CreatureModule = {
    Init: (self: CreatureModule, context: Init_Context) -> (),
    Start: (self: CreatureModule) -> (),
}

export type ComponentConfig = {
    Mode: "Plane",
    StartTime: number,
    StartSpeed: number,
    Duration: number,
    GetDirection: () -> Vector2,
    Curve: string,
}

export type LinearVelocityConfig = {
    Mode: "Line",
} | {
    Mode: "Plane",
    ForceLimitMode: Enum.ForceLimitMode,
    MaxForce: number,
    ForceLimitsEnabled: boolean,
    RelativeTo: Enum.ActuatorRelativeTo,
    PlaneVelocity: Vector2,
    PrimaryTangentAxis: Vector3,
    SecondaryTangentAxis: Vector3,
} | {
    Mode: "Vector",
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil
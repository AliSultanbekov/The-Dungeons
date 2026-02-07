--[=[
    @class Types
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local EntityServiceServer = require("EntityServiceServer")
local Signal = require("Signal")
local EntityTypesServer = require("EntityTypesServer")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --
export type AbilityExpiredSignalPacket = {
    Character: Model,
    AbilityData: EntityTypesServer.BaseAbility
}

export type Init_Context = {
    EntityServiceServer: EntityServiceServer.Module,
    PublicSignals: PublicSignals
}

export type PublicSignals = {
    CreatureCreated: Signal.Signal<Model>,
    CreatureDeleted: Signal.Signal<Model>,
    AbilityExpired: Signal.Signal<AbilityExpiredSignalPacket>
}

export type CreatureModule = {
    Init: (self: CreatureModule, context: Init_Context) -> (),
    Start: (self: CreatureModule) -> (),
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil

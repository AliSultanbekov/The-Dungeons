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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --

-- [ Types ] --
export type AbilityExpiredSignalPacket = {
    Character: Model,
    AbilityData: EntityTypesClient.BaseAbility
}

export type Init_Context = {
    EntityServiceClient: EntityServiceClient.Module, 
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
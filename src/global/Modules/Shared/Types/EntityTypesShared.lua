--[=[
    @class EntityTypes
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
export type EntityUpdatedRemotePacket = {
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

export type EntityCreatedRemotePacket = {
    Entity: Jecs.Entity,
    Tags: { string },
    Components: { [string]: any },
}

export type EntityDeletedRemotePacket = {
    Entity: Jecs.Entity,
}

export type EntitySyncRemotePacket = {
    {
        Entity: Jecs.Entity,
        Tags: { string },
        Components: {
            [string]: any
        }
    }
}

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil
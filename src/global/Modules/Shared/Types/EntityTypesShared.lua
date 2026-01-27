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
export type ReplicateComponentChangeRemotePacket = {
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

-- [ Private Functions ] --

-- [ Public Functions ] --

return nil
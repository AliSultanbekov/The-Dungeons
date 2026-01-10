-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Context = {
    Attacker: Model,
}

export type AbilityObject = {
    Activate: (self: AbilityObject, Context) -> ()
}

export type AbilityModule = {
    __index: AbilityModule,
    new: (config: any) -> AbilityObject,
}

return nil
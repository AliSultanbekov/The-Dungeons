-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Context = {
    Attacker: Model,
}

export type AbilityModule = {
    Activate: (self: AbilityModule, Context) -> ()
}

return nil
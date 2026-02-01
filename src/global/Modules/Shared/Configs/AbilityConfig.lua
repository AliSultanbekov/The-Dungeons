--[=[
    @class AbilityConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AbilityConfig = {
    ["DefaultBasicAttack"] = {
        Cooldown = 2,
        Weight = 1,
    }
}

-- [ Types ] --
export type Module = typeof(AbilityConfig)

return AbilityConfig :: Module
--[=[
    @class AbilityConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AbilityConfig = {
    ["DefaultBasicAttack"] = {
        Cooldown = 2
    }
}

-- [ Types ] --
export type Module = typeof(AbilityConfig)

return AbilityConfig :: Module
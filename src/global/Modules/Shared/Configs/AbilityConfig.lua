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
        CooldownDuration = 0.25,
        Weight = 1,
        
    },
    ["Block"] = {
        CooldownDuration = 0.5,
        Weight = 2,
    }
}

-- [ Types ] --
export type Module = typeof(AbilityConfig)

return AbilityConfig :: Module
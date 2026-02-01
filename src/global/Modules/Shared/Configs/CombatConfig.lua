--[=[
    @class Config
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Config = {
    ParryWindowTime = 0.25
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(Config) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Config :: Module
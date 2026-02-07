--[=[
    @class AnimationConstants
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AnimationConstants = {
    CreatureLayers = {
        Base = 1,
        Movement = 2,
        Combat = 3
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(AnimationConstants) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return AnimationConstants :: Module
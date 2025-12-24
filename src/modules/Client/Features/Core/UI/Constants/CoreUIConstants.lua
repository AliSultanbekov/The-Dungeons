--[=[
    @class CoreUIConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CoreUIConstants = {
    Screens = {
        "Main",
        "HUD",
    }
}

-- [ Types ] --
export type Module = typeof(CoreUIConstants)

return CoreUIConstants :: Module
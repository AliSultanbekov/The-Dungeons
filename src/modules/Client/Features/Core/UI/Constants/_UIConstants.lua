--[=[
    @class UIConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UIConstants = {
    Screens = {
        "UIs",
    }
}

-- [ Types ] --
export type Module = typeof(UIConstants)

return UIConstants :: Module
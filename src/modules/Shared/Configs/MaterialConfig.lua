--[=[
    @class MaterialConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MaterialConfig = {
    ["Sam's Foot"] = {
        Image = "rbxassetid://...",
        Rarity = "Common"
    }
}

-- [ Types ] --
export type Module = typeof(MaterialConfig)

return MaterialConfig :: Module
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
    ["Wooden Plank"] = {
        Image = "rbxassetid://91411232784138",
        Rarity = "Common"
    }
} :: {
    [string]: {
        Image: string,
        Rarity: string
    }
}

-- [ Types ] --
export type Module = typeof(MaterialConfig)

return MaterialConfig :: Module
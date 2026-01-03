--[=[
    @class ItemConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemConstants = {
    ItemTypeToStorageType = {
        ["Materials"] = "Stackable",
        ["Weapons"] = "Unqiue",
    }
}

-- [ Types ] --
export type Module = typeof(ItemConstants)

return ItemConstants :: Module
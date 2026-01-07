--[=[
    @class ItemDataUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local WeaponConfig = require("WeaponConfig")
local MaterialConfig = require("MaterialConfig")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemDataUtil = {}

-- [ Types ] --
type ItemType = ItemTypes.ItemType
export type Module = typeof(ItemDataUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function ItemDataUtil.GetConfig(self: Module, itemType: ItemType): any
    if itemType == "Weapons" then
        return WeaponConfig
    elseif itemType == "Materials" then
        return MaterialConfig
    end

    error(`Invalid ItemType: {itemType}`)
end

return ItemDataUtil :: Module
--[=[
    @class WeaponUIClass
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local UniqueUIClass = require("_UniqueUIClass")

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local ItemTypes = require("ItemTypes")

-- [ Variables ] --

-- [ Module Table ] --
local WeaponUIClass = setmetatable({}, UniqueUIClass)
WeaponUIClass.__index = WeaponUIClass

-- [ Types ] --
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)
type ItemType = ItemTypes.ItemType
type ItemData = ItemTypes.WeaponItemData

export type ObjectData = {

}
export type Object = ObjectData & Module
export type Module = typeof(WeaponUIClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeaponUIClass.new(ui: ItemUI, itemData: ItemData): Object
    local self = setmetatable(UniqueUIClass.new(ui, itemData) :: any, WeaponUIClass) :: Object
    
    return self
end

return WeaponUIClass :: Module
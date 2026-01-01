--[=[
    @class WeaponUIClass
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local UniqueUIClass = require("../_UniqueUIClass")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local ItemTypes = require("ItemTypes")
local WeaponConfig = require("WeaponConfig")
local ItemUIUtil = require("ItemUIUtil")

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
export type Object = ObjectData & Module & UniqueUIClass.Object
export type Module = typeof(WeaponUIClass)

-- [ Private Functions ] --
function WeaponUIClass._UpdateUI(self: Object)
    local ItemName = self:GetItemData().Name
    local ItemRarity = WeaponConfig[ItemName].Rarity
    local ItemImage = WeaponConfig[ItemName].Image

    local UI = self:GetUI()
    
    UI.ItemImage.Image = ItemImage
    ItemUIUtil:SetupForRarity(UI, ItemRarity)
end

-- [ Public Functions ] --
function WeaponUIClass.new(ui: ItemUI, itemData: ItemData): Object
    local self = setmetatable(UniqueUIClass.new(ui, itemData) :: any, WeaponUIClass) :: Object

    self:_UpdateUI()
    
    return self
end

return WeaponUIClass :: Module
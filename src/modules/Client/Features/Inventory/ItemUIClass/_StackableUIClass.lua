--[=[
    @class StackableUIClass
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local ItemUIClass = require("./_ItemUIClass")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local ItemTypes = require("ItemTypes")
local UpdateTextWithShadow = require("UpdateTextWithShadow")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StackableUIClass = setmetatable({}, ItemUIClass)
StackableUIClass.__index = StackableUIClass

-- [ Types ] --
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.ItemUI)
type ItemData = ItemTypes.StackableItemData
type ItemID = ItemTypes.ItemID

export type ObjectData = {
    _ItemData: ItemData
}
export type Object = ObjectData & Module & ItemUIClass.Object
export type Module = typeof(StackableUIClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function StackableUIClass.new(ui: ItemUI, itemData: ItemData): Object
    local self = setmetatable(ItemUIClass.new(ui), StackableUIClass) :: Object

    self._ItemData = itemData

    self._ItemCounter:Add(itemData.Amount)

    UpdateTextWithShadow(self._ItemUI.ItemName, self._ItemData.Name)

    return self
end

function StackableUIClass.AddItemData(self: Object, itemData: ItemData)
    self._ItemData.Amount += itemData.Amount

    self._ItemCounter:Add(itemData.Amount)
end

function StackableUIClass.RemoveItemData(self: Object, itemData: ItemData)
    self._ItemData.Amount -= itemData.Amount

    self._ItemCounter:Add(-itemData.Amount)
end


return StackableUIClass :: Module   
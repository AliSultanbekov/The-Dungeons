--[=[
    @class ItemUIClass
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Maid = require("Maid")
local Counter = require("Counter")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemUIClass = {}
ItemUIClass.__index = ItemUIClass

-- [ Types ] --
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)
type ItemType = ItemTypes.ItemType
type ItemData = ItemTypes.ItemData

export type ObjectData = {
    _Maid: Maid.Maid,
    _ItemUI: ItemUI,
    _ItemCounter: Counter.Counter,
}
export type Object = ObjectData & Module
export type Module = typeof(ItemUIClass)

-- [ Private Functions ] --
function ItemUIClass._ItemCountChanged(self: Object, newCount: number)
    if newCount <= 1 then
        self._ItemUI.ItemAmount.Visible = false
    else
        self._ItemUI.ItemAmount.Visible = true
    end

    self._ItemUI.ItemAmount.Text = string.format("x%d", newCount)
end

-- [ Public Functions ] --
function ItemUIClass.new(ui: ItemUI): Object
    local self = setmetatable({} :: any, ItemUIClass) :: Object

    self._ItemUI = ui

    self._ItemCounter = Counter.new(); self._ItemCounter.Changed:Connect(function(newCount: number)
        self:_ItemCountChanged(newCount)
    end)

    return self
end

function ItemUIClass.GetItemData(self: Object): ItemData
    error("this shouldnt be called")
end

function ItemUIClass.AddItemData(self: Object, itemData: ItemData)
end

function ItemUIClass.RemoveItemData(self: Object, itemData: ItemData)
end

function ItemUIClass.GetUI(self: Object)
    return self._ItemUI
end

function ItemUIClass.IsEmpty(self: Object)
    return self._ItemCounter:GetValue() == 0
end

return ItemUIClass :: Module
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
    _ItemCount: Counter.Counter,
    _DeleteCount: Counter.Counter,
}
export type Object = ObjectData & Module
export type Module = typeof(ItemUIClass)

-- [ Private Functions ] --
function ItemUIClass._ItemCountChanged(self: Object, newCount: number)
    if self._DeleteCount:GetValue() > 0 then
        return
    end

    if newCount <= 1 then
        self._ItemUI.ItemAmount.Visible = false
    else
        self._ItemUI.ItemAmount.Visible = true
    end

    self._ItemUI.ItemAmount.Text = string.format("x%d", newCount)
    self._ItemUI.ItemAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
end

function ItemUIClass._DeleteCountChanged(self: Object, newDeleteCount)
    if newDeleteCount == 0 then
        return
    end

    self._ItemUI.ItemAmount.Visible = true
    print(self._ItemCount:GetValue())
    if self._ItemCount:GetValue() == 0 then
        self._ItemUI.ItemAmount.Text = "-Max"
    else
        self._ItemUI.ItemAmount.Text = string.format("-%d", newDeleteCount)
    end

    self._ItemUI.ItemAmount.TextColor3 = Color3.fromRGB(255, 90, 90)

    task.defer(function()
        print(self._ItemCount:GetValue())
    end)
end

-- [ Public Functions ] --
function ItemUIClass.new(ui: ItemUI): Object
    local self = setmetatable({} :: any, ItemUIClass) :: Object

    self._ItemUI = ui

    self._ItemCount = Counter.new(); self._ItemCount.Changed:Connect(function(newCount: number)
        self:_ItemCountChanged(newCount)
    end)
    self._DeleteCount = Counter.new(); self._DeleteCount.Changed:Connect(function(newDeleteCount: number)
        self:_DeleteCountChanged(newDeleteCount)
    end)

    return self
end

function ItemUIClass.ClearHoldBag(self: Object, itemData: ItemData?)
    error("this shouldnt be called")
end

function ItemUIClass.AddToHoldBag(self: Object, itemData: ItemData)
    error("this shouldnt be called")
end

function ItemUIClass.GetItemData(self: Object): ItemData
    error("this shouldnt be called")
end

function ItemUIClass.AddItemData(self: Object, itemData: ItemData)
    error("this shouldnt be called")
end

function ItemUIClass.RemoveItemData(self: Object, itemData: ItemData)
    error("this shouldnt be called")
end

function ItemUIClass.GetUI(self: Object)
    return self._ItemUI
end

function ItemUIClass.IsEmpty(self: Object)
    return self._ItemCount:GetValue() == 0
end

return ItemUIClass :: Module
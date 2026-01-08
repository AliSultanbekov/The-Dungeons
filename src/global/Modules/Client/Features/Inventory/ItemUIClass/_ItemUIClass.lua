--[=[
    @class ItemUIClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ItemUIClassTypes = require("./_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Counter = require("Counter")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --
local DEFAULT_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local MARKED_TEXT_COLOR = Color3.fromRGB(255, 56, 56)

-- [ Variables ] --

-- [ Module Table ] --
local ItemUIClass = {}
ItemUIClass.__index = ItemUIClass

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type ItemUI = ItemUIClassTypes.ItemUI
type Behaviors = ItemUIClassTypes.Behaviors
type UIBehavior = ItemUIClassTypes.UIBehavior
type ItemDataBehavior = ItemUIClassTypes.ItemDataBehavior

type Context = {
    ItemUI: ItemUI,
    Behaviors: Behaviors,
    ItemCount: Counter.Counter,
    MarkCount: Counter.Counter,
}
export type ObjectData = {
    _ItemUI: ItemUI,
    _Behaviors: Behaviors,
    _ItemCount: Counter.Counter,
    _MarkedCount: Counter.Counter,
}
export type Object = ObjectData & ItemDataBehavior & UIBehavior & {
    _UpdateItemAmount: (self: Object) -> (),
    GetUI: (self: Object) -> ItemUI,
    IsEmpty: (self: Object) -> (),
    MaxMarked: (self: Object) -> (),
}
export type Module = {
    __index: Module,    
    new: (context: Context) -> Object,
}

-- [ Private Functions ] --
function ItemUIClass._UpdateItemAmount(self: Object)
    local ItemCount = self._ItemCount:GetValue()
    local MarkedCount = self._MarkedCount:GetValue()
    local UI = self._ItemUI

    if MarkedCount > 0 then
        UI.ItemAmount.Visible = true
            UI.ItemAmount.TextColor3 = MARKED_TEXT_COLOR
            if MarkedCount == ItemCount then
            UI.ItemAmount.Text = "-Max"
        else
            UI.ItemAmount.Text = string.format("-%d", MarkedCount)
        end
    else
        UI.ItemAmount.TextColor3 = DEFAULT_TEXT_COLOR
        if ItemCount <= 1 then
            UI.ItemAmount.Visible = false
        else
            UI.ItemAmount.Visible = true
            UI.ItemAmount.Text = string.format("x%d", ItemCount)
        end
    end
end

function ItemUIClass.UpdateUI(self: Object)
    self._Behaviors.UI:UpdateUI()
end

-- [ Public Functions ] --
function ItemUIClass.new(context: Context): Object
    local self = setmetatable({} :: any, ItemUIClass) :: Object

    self._ItemUI = context.ItemUI
    self._Behaviors = context.Behaviors

    self._ItemCount = context.ItemCount
    self._MarkedCount = context.MarkCount

    self._ItemCount.Changed:Connect(function()
        self:_UpdateItemAmount()
    end)

    self._MarkedCount.Changed:Connect(function()
        self:_UpdateItemAmount()
    end)

    self:_UpdateItemAmount()
    self:UpdateUI()

    return self
end

function ItemUIClass.GetUI(self: Object): ItemUI
    return self._ItemUI
end

function ItemUIClass.IsEmpty(self: Object): boolean
    return self._ItemCount:GetValue() <= 0
end

function ItemUIClass.MaxMarked(self: Object): boolean
    return self._MarkedCount:GetValue() >= self._ItemCount:GetValue()
end

function ItemUIClass.GetItemData(self: Object, id: string?, ignoreMarked: boolean?): ItemData
    return self._Behaviors.ItemData:GetItemData(id, ignoreMarked)
end

function ItemUIClass.ClearMarked(self: Object)
    self._Behaviors.ItemData:ClearMarked()
end

function ItemUIClass.Mark(self: Object, itemData: ItemData)
    self._Behaviors.ItemData:Mark(itemData)
end

function ItemUIClass.Unmark(self: Object, itemData: ItemData)
    self._Behaviors.ItemData:Unmark(itemData)
end

function ItemUIClass.AddItemData(self: Object, itemData: ItemData)
    self._Behaviors.ItemData:AddItemData(itemData)
end

function ItemUIClass.RemoveItemData(self: Object, itemData: ItemData)
    self._Behaviors.ItemData:RemoveItemData(itemData)
end

return ItemUIClass :: Module
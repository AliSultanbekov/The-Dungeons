--[=[
    @class StackableBehavior
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ItemUIClassTypes = require("../../_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local ItemTypes = require("ItemTypes")
local Counter = require("Counter")
local Table = require("Table")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StackableBehavior = {}
StackableBehavior.__index = StackableBehavior

-- [ Types ] --
type ItemData = ItemTypes.StackableItemData
type ItemDataBehavior = ItemUIClassTypes.ItemDataBehavior
type Context = {
    ItemData: ItemData,
    ItemCount: Counter.Counter,
    MarkedCount: Counter.Counter
}
export type ObjectData = {
    _ItemData: ItemData,
    _ItemCount: Counter.Counter,
    _MarkedCount: Counter.Counter,
}
export type Object = ObjectData & ItemDataBehavior
export type Module = {
    __index: Module,
    new: (context: Context) -> Object,
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function StackableBehavior.new(context: Context): Object
    local self = setmetatable({} :: any, StackableBehavior) :: Object

    self._ItemData = context.ItemData
    self._ItemCount = context.ItemCount
    self._MarkedCount = context.MarkedCount
    
    return self
end

function StackableBehavior.GetItemData(self: Object, ignoreMarked: boolean?)
    if ignoreMarked then
        if self._ItemData.Amount - self._MarkedCount:GetValue() <= 0 then
            error("[StackableBehavior] No unmarked items left!")
        end
    end

    local Data = Table.deepCopy(self._ItemData)
    Data.Amount = 1

    return Data
end

function StackableBehavior.ClearMarked(self: Object)
    local MarkedCount = self._MarkedCount:GetValue()

    if MarkedCount == 0 then
        warn("[StackableBehavior] ClearMarked called when no items are marked")
        return
    end

    self._MarkedCount:Add(-MarkedCount)
end

function StackableBehavior.Mark(self: Object, itemData: ItemData)
    if self._ItemCount:GetValue() < self._MarkedCount:GetValue() + itemData.Amount then
        error("[StackableBehavior] Not enough items to mark!")
    end

    self._MarkedCount:Add(itemData.Amount)
end

function StackableBehavior.Unmark(self: Object, itemData: ItemData)
    if self._MarkedCount:GetValue() - itemData.Amount <= 0 then
        error("[StackableBehavior] Cannot unmark more items than currently marked!")
    end

    self._MarkedCount:Add(-itemData.Amount)
end

function StackableBehavior.AddItemData(self: Object, itemData: ItemData, itemCount: Counter.Counter)
    self._ItemData.Amount += itemData.Amount
    itemCount:Add(itemData.Amount)
end

function StackableBehavior.RemoveItemData(self: Object, itemData: ItemData, itemCount: Counter.Counter)
    if self._ItemData.Amount < itemData.Amount then
        error("[StackableBehavior] Not enough items to remove!")
    end
    
    self._ItemData.Amount -= itemData.Amount
    itemCount:Add(-itemData.Amount)
end

return StackableBehavior :: Module
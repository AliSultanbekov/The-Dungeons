--[=[
    @class UniqueBehavior
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ItemUIClassTypes = require("../../_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Counter = require("Counter")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UniqueBehavior = {}
UniqueBehavior.__index = UniqueBehavior

-- [ Types ] --
type ItemData = ItemTypes.UniqueItemData
type ItemDataBehavior = ItemUIClassTypes.ItemDataBehavior
type Context = {
    ItemData: ItemData,
    ItemCount: Counter.Counter,
    MarkedCount: Counter.Counter,
}
export type ObjectData = {
    _ItemCount: Counter.Counter,
    _MarkedCount: Counter.Counter,
    _ItemBag: { [string]: ItemData },
    _NonMarkedBag: { [string]: ItemData },
    _MarkedBag: { [string]: ItemData }
}
export type Object = ObjectData & ItemDataBehavior
export type Module = {
    __index: Module,
    new: (context: Context) -> Object,
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function UniqueBehavior.new(context: Context): Object
    local self = setmetatable({} :: any, UniqueBehavior) :: Object

    self._ItemCount = context.ItemCount
    self._MarkedCount = context.MarkedCount

    self._ItemBag = { [context.ItemData.ID] = context.ItemData }
    self._NonMarkedBag = { [context.ItemData.ID] = context.ItemData }
    self._MarkedBag = {}
    
    return self
end

function UniqueBehavior.GetItemData(self: Object, ignoreMarked: boolean?): ItemData
    local ItemData

    if ignoreMarked then
        local Key = next(self._NonMarkedBag)

        if not Key then
            error("[UnqiueUIClass] No ItemData found in _NonMarkedBag")
        end

        ItemData = self._ItemBag[Key]
    else
        local Key = next(self._ItemBag)

        if not Key then
            error("[UnqiueUIClass] No ItemData found in _ItemBag")
        end

        ItemData = self._ItemBag[Key]
    end

    return ItemData
end

function UniqueBehavior.ClearMarked(self: Object)
    if self._MarkedCount:GetValue() == 0 then
        warn("[UnqiueUIClass] ClearMarked called when no items are marked")
        return
    end

    local Count = 0

    for _, itemData in self._MarkedBag do
        self._MarkedBag[itemData.ID] = nil
        self._NonMarkedBag[itemData.ID] = itemData
        Count += 1
    end

    self._MarkedCount:Add(-Count)
end

function UniqueBehavior.Mark(self: Object, itemData: ItemData)
    if self._MarkedBag[itemData.ID] or not self._NonMarkedBag[itemData.ID] then
        warn("[UnqiueUIClass] Attempted to mark invalid or already marked itemData with ID: " .. tostring(itemData.ID))
        return
    end

    self._NonMarkedBag[itemData.ID] = nil
    self._MarkedBag[itemData.ID] = itemData
    
    self._MarkedCount:Add(1)
end

function UniqueBehavior.Unmark(self: Object, itemData: ItemData)
    local function unMark(itemData: ItemData)
        self._MarkedBag[itemData.ID] = nil
        self._NonMarkedBag[itemData.ID] = itemData
        self._MarkedCount:Add(-1)
    end

    if itemData then
        if self._MarkedBag[itemData.ID] or not self._NonMarkedBag[itemData.ID] then
            warn("[UnqiueUIClass] Attempted to mark invalid or already marked itemData with ID: " .. tostring(itemData.ID))
            return
        end

        unMark(itemData)
    else
        for _, itemData in self._MarkedBag do
            unMark(itemData)
        end
    end
end

function UniqueBehavior.AddItemData(self: Object, itemData: ItemData, itemCount: Counter.Counter)
    if self._ItemBag[itemData.ID] then
        warn("[UnqiueUIClass] Attempted to add duplicate itemData with ID: " .. tostring(itemData.ID))
        return
    end

    self._ItemBag[itemData.ID] = itemData
end

function UniqueBehavior.RemoveItemData(self: Object, itemData: ItemData, itemCount: Counter.Counter)
    if not self._ItemBag[itemData.ID] then
        warn("[UnqiueUIClass] Attempted to delete non-existent itemData with ID: " .. tostring(itemData.ID))
        return
    end

    self._ItemBag[itemData.ID] = nil
end

return UniqueBehavior :: Module
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[=[
    @class UnqiueUIClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ItemUIClass = require("./_ItemUIClass")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UnqiueUIClass = setmetatable({}, ItemUIClass)
UnqiueUIClass.__index = UnqiueUIClass

-- [ Types ] --
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.ItemUI)
type ItemData = ItemTypes.ItemData
type ItemID = ItemTypes.ItemID

export type ObjectData = {
    _ItemsData: { [ItemID]: ItemData },
}
export type Object = ObjectData & Module & ItemUIClass.Object
export type Module = typeof(UnqiueUIClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function UnqiueUIClass.new(ui: ItemUI, itemData: ItemData): Object
    local self = setmetatable(ItemUIClass.new(ui), UnqiueUIClass) :: Object
    
    self._ItemsData = { [itemData.ID] = itemData }

    return self
end

function UnqiueUIClass.AddItemData(self: Object, itemData: ItemData)
    if self._ItemsData[itemData.ID] then
        warn(`ItemData with ID {itemData.ID} already exists in _ItemsData`)
        return
    end

    self._ItemsData[itemData.ID] = itemData
    self._ItemCounter:Add(1)
end

function UnqiueUIClass.RemoveItemData(self: Object, itemData: ItemData)
    if not self._ItemsData[itemData.ID] then
        warn(`ItemData with ID {itemData.ID} does not exist in _ItemsData`)
        return
    end

    self._ItemsData[itemData.ID] = nil
    self._ItemCounter:Add(-1)
end

return UnqiueUIClass :: Module
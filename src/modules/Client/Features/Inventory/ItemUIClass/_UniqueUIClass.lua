--[=[
    @class UnqiueUIClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ItemUIFactory = require("../Factories/_ItemUIFactory")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local Maid = require("Maid")
local Counter = require("Counter")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UnqiueUIClass = {}
UnqiueUIClass.__index = UnqiueUIClass

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type ItemID = ItemTypes.ItemID

export type ObjectData = {
    _Maid: Maid.Maid,

    _ItemUI: {
        Instance: GuiButton,
        Refs: ItemUIFactory.Refs
    },

    _ItemsData: { [ItemID]: ItemData },
    _ItemsCounter: Counter.Counter,
}
export type Object = ObjectData & Module
export type Module = typeof(UnqiueUIClass)

-- [ Private Functions ] --
function _ItemCountChanged(self: Object, newCount: number)
    
end

-- [ Public Functions ] --
function UnqiueUIClass.new(ui: GuiButton): Object
    local self = setmetatable({} :: any, UnqiueUIClass) :: Object
    
    self._Maid = Maid.new()

    self._ItemUI = {
        Instance = ui,
        Refs = ItemUIFactory:ProduceRefs(ui)
    }
    
    self._ItemsData = {}
    self._ItemsCounter = Counter.new()

    self._ItemsCounter.Changed:Connect(function(newCount: number)
        _ItemCountChanged(self, newCount)
    end)

    return self
end

function UnqiueUIClass.AddItemData(self: Object, itemData: ItemData)
    if self._ItemsData[itemData.ID] then
        warn(`ItemData with ID {itemData.ID} already exists in _ItemsData`)
        return
    end

    self._ItemsData[itemData.ID] = itemData
    self._ItemsCounter:Add(1)
end

function UnqiueUIClass.RemoveItemData(self: Object, itemData: ItemData)
    if not self._ItemsData[itemData.ID] then
        warn(`ItemData with ID {itemData.ID} does not exist in _ItemsData`)
        return
    end

    self._ItemsData[itemData.ID] = nil
    self._ItemsCounter:Add(-1)
end

return UnqiueUIClass :: Module
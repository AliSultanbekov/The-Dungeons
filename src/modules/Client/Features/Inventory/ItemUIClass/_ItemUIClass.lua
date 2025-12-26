--[=[
    @class ItemUIClass
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Maid = require("Maid")
local Counter = require("Counter")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemUIClass = {}
ItemUIClass.__index = ItemUIClass

-- [ Types ] --
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)

export type ObjectData = {
    _Maid: Maid.Maid,
    _ItemUI: ItemUI,
    _ItemCounter: Counter.Counter,
}
export type Object = ObjectData & Module
export type Module = typeof(ItemUIClass)

-- [ Private Functions ] --
function ItemUIClass._ItemCountChanged(newCount: number)
    
end

-- [ Public Functions ] --
function ItemUIClass.new(ui: ItemUI): Object
    local self = setmetatable({} :: any, ItemUIClass) :: Object

    self._Maid = Maid.new()
    self._ItemUI = ui

    self._ItemCounter = Counter.new(); self._ItemCounter.Changed:Connect(function(newCount: number)
        self._ItemCountChanged(newCount)
    end)

    return self
end

return ItemUIClass :: Module
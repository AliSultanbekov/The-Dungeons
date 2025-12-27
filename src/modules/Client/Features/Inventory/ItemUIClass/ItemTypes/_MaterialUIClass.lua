--[=[
    @class MaterialUIclass
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local StackableUIClass = require("../_StackableUIClass")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MaterialUIclass = setmetatable({}, StackableUIClass)
MaterialUIclass.__index = MaterialUIclass

-- [ Types ] --
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)
type ItemType = ItemTypes.ItemType
type ItemData = ItemTypes.MaterialItemData

export type ObjectData = {
    
}
export type Object = ObjectData & Module & StackableUIClass.Object
export type Module = typeof(MaterialUIclass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function MaterialUIclass.new(ui: ItemUI, itemData: ItemData): Object
    local self = setmetatable(StackableUIClass.new(ui, itemData), MaterialUIclass) :: Object

    return self
end

return MaterialUIclass :: Module
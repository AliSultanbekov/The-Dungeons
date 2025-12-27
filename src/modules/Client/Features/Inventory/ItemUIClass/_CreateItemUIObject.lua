--[=[
    @class GetItemUIObject
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local UniqueUIClass = require("./_UniqueUIClass")
local StackableUIClass = require("./_StackableUIClass")
local ItemUIClass = require("./_ItemUIClass")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreateItemUIObject = function(ui: ItemUI, itemData: ItemData): ItemUIObject
    if itemData.Type == "Materials" then
        return StackableUIClass.new(ui, itemData)
    elseif itemData.Type == "Weapons" then
        return UniqueUIClass.new(ui, itemData)
    else
        error(`[GetItemUIObject] Unknown itemType: {itemData.Type}`)
    end
end

-- [ Types ] --
export type ItemUIObject = ItemUIClass.Object
type ItemType = ItemTypes.ItemType
type ItemData = ItemTypes.ItemData
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)

export type Module = typeof(CreateItemUIObject)

-- [ Private Functions ] --

-- [ Public Functions ] --

return CreateItemUIObject :: Module
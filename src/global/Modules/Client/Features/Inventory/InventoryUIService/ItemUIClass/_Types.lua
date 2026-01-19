-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Types ] --
export type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)
export type Behaviors = {
    ["ItemData"]: ItemDataBehavior,
    ["UI"]: UIBehavior
}
export type BehaviorType = "ItemData" | "UI"
export type ItemDataBehavior = {
    GetItemData: (self: ItemDataBehavior, id: string?, ignoreMarked: boolean?) -> ItemTypes.ItemData,
    ClearMarked: (self: ItemDataBehavior) -> (),
    Unmark: (self: ItemDataBehavior, itemData: ItemTypes.ItemData) -> (),
    Mark: (self: ItemDataBehavior, itemData: ItemTypes.ItemData) -> (),
    AddItemData: (self: ItemDataBehavior, itemData: ItemTypes.ItemData) -> (),
    RemoveItemData: (self: ItemDataBehavior, itemData: ItemTypes.ItemData) -> (),
}
export type UIBehavior = {
    UpdateUI: (self: UIBehavior) -> (),
}
export type ItemConfig = {
    [string]: {
        Rarity: string,
        Image: string,
        [any]: any,
    }
}

return nil
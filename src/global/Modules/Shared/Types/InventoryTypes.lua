-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Types ] --
type ItemData = ItemTypes.ItemData
export type GetItemsDataRemotePacket = { [string]: ItemTypes.ItemData }
export type RemoveItemsRemotePacket = { [string]: ItemTypes.ItemData }
export type EquipItemRemotePacket = ItemData
export type UnequipItemRemotePacket = ItemData

export type ItemsAddedRemotePacket = { [string]: ItemTypes.ItemData }
export type ItemsRemovedRemotePacket = { [string]: ItemTypes.ItemData }
export type ItemUpdatedRemotePacket = ItemData

return nil
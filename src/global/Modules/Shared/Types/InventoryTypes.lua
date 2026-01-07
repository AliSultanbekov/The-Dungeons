-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Types ] --
export type GetItemDatasRemotePacket = { [string]: ItemTypes.ItemData }

export type ItemsAddedRemotePacket = { [string]: ItemTypes.ItemData }

export type ItemsRemovedRemotePacket = { [string]: ItemTypes.ItemData }

export type ItemUnequippedRemotePacket = ItemTypes.ItemData

export type ItemEquippedRemotePacket = ItemTypes.ItemData

return nil
-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type ItemType = "Weapons" | "Materials" | string
export type ItemID = string

export type RawMaterialItemData = {
    Name: string,
    Type: "Materials",
    Amount: number,
}

export type RawWeaponItemData = {
    Name: string,
    Type: "Weapons",
}

export type RawItemData = RawMaterialItemData | RawWeaponItemData

export type MaterialItemData = {
    ID: ItemID,
    Name: string,
    Type: "Materials",
    Amount: number,
}

export type WeaponItemData = {
    ID: ItemID,
    Name: string,
    Type: "Weapons",
}

export type ItemData = MaterialItemData | WeaponItemData

export type StackableItemData = {
	ID: ItemID,
	Name: string,
	Type: "Materials",
	Amount: number,
}

export type UniqueItemData = {
	ID: ItemID,
	Name: string,
	Type: "Weapons",
}

return {}
-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type ItemType = "Weapons" | "Materials" | string

export type ItemID = string

export type RawMaterialData = {
    Type: "Materials" | string,
    Name: string,
    Amount: number,
}

export type RawWeaponData = {
    Type: "Weapons" | string,
    Name: string,
}

export type MaterialData = {
    ID: string,
    Type: "Weapons" | string,
    Name: string,
}

export type WeaponData = {
    ID: string,
    Type: "Materials" | string,
    Name: string,
    Amount: number,
}

export type RawItemData = RawWeaponData & RawMaterialData

export type ItemData = WeaponData & MaterialData

return {}
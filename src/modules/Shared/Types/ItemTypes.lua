-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type ItemID = string

export type RawWeaponData = {
    Type: "Weapons" | string,
    Name: string,
}

export type WeaponData = {
    ID: string,
    
} & RawWeaponData

export type RawItemData = RawWeaponData

export type ItemData = WeaponData

return {}
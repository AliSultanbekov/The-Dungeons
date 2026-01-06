--[=[
    @class ItemTypes
]=]

-- [ Types ] --
export type ItemID = string

-- ============================================================================
-- RAW ITEM DATA (Input from game logic, before processing)
-- ============================================================================

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

-- ============================================================================
-- PROCESSED ITEM DATA (After adding ID, ready for storage)
-- ============================================================================

-- Materials are stackable
export type MaterialItemData = {
    ID: ItemID,
    Name: string,
    Type: "Materials",
    Amount: number,
}

-- Weapons are unique
export type WeaponItemData = {
    ID: ItemID,
    Name: string,
    Type: "Weapons",
}

-- Union of all specific item types
export type ItemData = MaterialItemData | WeaponItemData

-- ============================================================================
-- GENERIC CATEGORIES (For type checking storage pattern)
-- ============================================================================

-- All stackable items must have Amount
export type StackableItemData = MaterialItemData  -- Add more stackable types here with |

-- All unique items don't have Amount
export type UniqueItemData = WeaponItemData  -- Add more unique types here with |

return {}
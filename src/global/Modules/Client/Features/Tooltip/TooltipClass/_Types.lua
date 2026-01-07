-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Types ] --
export type Behavior = {
    UpdateUI: (self: Behavior, info: any?) -> (),
    UpdateCbs: ((self: Behavior, cbs: { [any]: any }) -> ()),
    Show: (self: Behavior) -> (),
    Hide: (self: Behavior) -> (),
}

export type Info = {
    ItemData: ItemTypes.ItemData, Config: Config
}

export type Config = {
    [string]: {
        Image: string,
        Rarity: string,
        [any]: any
    }
}

return nil
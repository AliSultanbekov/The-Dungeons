--[=[
    @class DefaultUIBehavior
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ItemUIClassTypes = require("../../_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemUIUtil = require("ItemUIUtil")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DefaultUIBehavior = {}
DefaultUIBehavior.__index = DefaultUIBehavior

-- [ Types ] --
type ItemConfig = ItemUIClassTypes.ItemConfig
type ItemUI = ItemUIClassTypes.ItemUI
type ItemData = ItemTypes.ItemData
type UIBehavior = ItemUIClassTypes.UIBehavior
type Context = {
    ItemUI: ItemUI,
    ItemData: ItemData,
    ItemConfig: ItemConfig
}
export type ObjectData = {
    _ItemUI: ItemUI,
    _ItemConfig: ItemConfig,
    _ItemData: ItemData
}
export type Object = ObjectData & UIBehavior
export type Module = {
    __index: Module,
    new: (context: Context) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function DefaultUIBehavior.new(context: Context): Object
    local self = setmetatable({} :: any, DefaultUIBehavior) :: Object

    self._ItemUI = context.ItemUI
    self._ItemData = context.ItemData
    self._ItemConfig = context.ItemConfig

    return self
end

function DefaultUIBehavior.UpdateUI(self: Object)
    local UI = self._ItemUI
    local ItemData = self._ItemData
    local ItemImage = self._ItemConfig[ItemData.Name].Image
    local ItemRarity = self._ItemConfig[ItemData.Name].Rarity

    UI.ItemImage.Image = ItemImage

    if ItemData.Equipped == true then
        UI.Equipped.Visible = true
    else
        UI.Equipped.Visible = false
    end

    UI.ItemName.Text = ItemData.Name

    ItemUIUtil:SetupForRarity(UI, ItemRarity)
end

return DefaultUIBehavior :: Module
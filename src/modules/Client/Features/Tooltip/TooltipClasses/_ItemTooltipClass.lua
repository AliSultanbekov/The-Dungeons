--[=[
    @class ItemTooltipClass
]=]

-- [ Roblox Services ] --
local StarterGui = game:GetService("StarterGui")

-- [ Imports ] --
local TooltipClass = require("./_TooltipClass")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local WeaponConfig = require("WeaponConfig")
local MaterialConfig = require("MaterialConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemTooltipClass = setmetatable({}, TooltipClass)
ItemTooltipClass.__index = ItemTooltipClass

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type ItemTooltipUI = typeof(StarterGui.Tooltips.ItemTooltipUI)
export type ObjectData = {
    _UI: ItemTooltipUI
}
export type Object = ObjectData & Module & TooltipClass.Object
export type Module = typeof(ItemTooltipClass)

-- [ Private Functions ] --
function ItemTooltipClass._UpdateWeaponInfo(self: Object, info: ItemData)
    local Config = WeaponConfig
    local ItemName = info.Name
    local Rarity = Config[ItemName].Rarity

    self._UI.Container.Header.Container.ItemName.Text = ItemName
    self._UI.Container.Header.Container.Rarity.Text = Rarity
end

function ItemTooltipClass._UpdateMaterialInfo(self: Object, info: ItemData)
    local Config = MaterialConfig
    local ItemName = info.Name
    local Rarity = Config[ItemName].Rarity

    self._UI.Container.Header.Container.ItemName.Text = ItemName
    self._UI.Container.Header.Container.Rarity.Text = Rarity
end

-- [ Public Functions ] --
function ItemTooltipClass.new(ui: ItemTooltipUI): Object
    local self = setmetatable(TooltipClass.new(ui), ItemTooltipClass) :: Object

    return self
end

function ItemTooltipClass.UpdateInfo(self: Object, info: ItemData)
    if info.Type == "Weapons" then
        self:_UpdateWeaponInfo(info)
    elseif info.Type == "Materials" then
        self:_UpdateMaterialInfo(info)
    end
end

return ItemTooltipClass :: Module
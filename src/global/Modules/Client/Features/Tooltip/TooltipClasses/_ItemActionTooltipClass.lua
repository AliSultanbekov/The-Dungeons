--[=[
    @class _ItemActionTooltipClass
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
local UIUtil = require("UIUtil")
local ButtonUtil = require("ButtonUtil")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --

-- [ Module Table ] --
local _ItemActionTooltipClass = setmetatable({}, TooltipClass)
_ItemActionTooltipClass.__index = _ItemActionTooltipClass

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type ItemActionTooltipUI = typeof(StarterGui.Tooltips.ItemActionTooltipUI)
export type ObjectData = {
    _UI: ItemActionTooltipUI
}
export type Object = ObjectData & Module & TooltipClass.Object
export type Module = typeof(_ItemActionTooltipClass)

-- [ Private Functions ] --
function _ItemActionTooltipClass._UpdateWeaponInfo(self: Object, info: ItemData)
    local Config = WeaponConfig
    local ItemName = info.Name
    local Rarity = Config[ItemName].Rarity

    self._UI.Container.Header.Container.ItemName.Text = ItemName
    self._UI.Container.Header.Container.Rarity.Text = Rarity
end

function _ItemActionTooltipClass._UpdateMaterialInfo(self: Object, info: ItemData)
    local Config = MaterialConfig
    local ItemName = info.Name
    local Rarity = Config[ItemName].Rarity

    self._UI.Container.Header.Container.ItemName.Text = ItemName
    self._UI.Container.Header.Container.Rarity.Text = Rarity
end

-- [ Public Functions ] --
function _ItemActionTooltipClass.new(ui: ItemActionTooltipUI): Object
    local self = setmetatable(TooltipClass.new(ui), _ItemActionTooltipClass) :: Object

    ButtonUtil:Hook(self._UI.Container.Content.Buttons.Close, nil, nil, function()
        if self._Callbacks.Close then
            self._Callbacks.Close()
        end
    end)

    return self
end

function _ItemActionTooltipClass.Show(self: Object)
    UIUtil:OpenUI(self._UI, OPEN_TWEENINFO, true)
end

function _ItemActionTooltipClass.Hide(self: Object)
    UIUtil:CloseUI(self._UI, CLOSE_TWEENINFO, true)
end

function _ItemActionTooltipClass.UpdateInfo(self: Object, info: ItemData)
    if info.Type == "Weapons" then
        self:_UpdateWeaponInfo(info)
    elseif info.Type == "Materials" then
        self:_UpdateMaterialInfo(info)
    end
end

return _ItemActionTooltipClass :: Module
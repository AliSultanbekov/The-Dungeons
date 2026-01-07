--[=[
    @class ItemActionBehavior
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local TooltipClassTypes = require("../_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Signal = require("Signal")
local UIUtil = require("UIUtil")
local ItemDataUtil = require("ItemDataUtil")
local ButtonUtil = require("ButtonUtil")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

-- [ Module Table ] --
local ItemActionBehavior = {}
ItemActionBehavior.__index = ItemActionBehavior

-- [ Types ] --
type ItemTooltipUI = typeof(PlayerGui.Tooltips.ItemActionTooltipUI)
type Behavior = TooltipClassTypes.Behavior
type Config = TooltipClassTypes.Config
type Info = TooltipClassTypes.Info
type Context = {
    UI: ItemTooltipUI,
    DestroySignal: Signal.Signal<nil>
}
export type ObjectData = {
    _UI: ItemTooltipUI,
    _Cbs: { [any]: any },
    _DestroySignal: Signal.Signal<nil>
}
export type Object = ObjectData & Behavior & {
    
}
export type Module = {
    __index: Module,
    new: (context: Context) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function ItemActionBehavior.new(context: Context): Object
    local self = setmetatable({} :: any, ItemActionBehavior) :: Object

    self._UI = context.UI
    self._Cbs = {}
    self._DestroySignal = context.DestroySignal

    ButtonUtil:Hook(self._UI.Container.Content.Buttons.Equip, nil, nil, function()
        self._DestroySignal:Fire()
        if self._Cbs.Equip then
            self._Cbs.Equip()
        end
    end)

    ButtonUtil:Hook(self._UI.Container.Content.Buttons.Unequip, nil, nil, function()
        self._DestroySignal:Fire()
        if self._Cbs.Unequip then
            self._Cbs.Unequip()
        end
    end)

    ButtonUtil:Hook(self._UI.Container.Content.Buttons.Close, nil, nil, function()
        self._DestroySignal:Fire()
    end)

    return self
end

function ItemActionBehavior.UpdateUI(self: Object, info: Info)
    local ItemData = info.ItemData
    local Config = ItemDataUtil:GetConfig(ItemData.Type)
    
    local ItemName = ItemData.Name
    local Rarity = Config[ItemName].Rarity

    self._UI.Container.Header.Container.ItemName.Text = ItemName
    self._UI.Container.Header.Container.Rarity.Text = Rarity

    local ButtonsContainer = self._UI.Container.Content.Buttons

    if ItemData.Equipped == true then
        ButtonsContainer.Equip.Visible = false
        ButtonsContainer.Unequip.Visible = true
    else
        ButtonsContainer.Equip.Visible = true
        ButtonsContainer.Unequip.Visible = false
    end
end

function ItemActionBehavior.UpdateCbs(self: Object, cbs: {})
    self._Cbs = cbs
end

function ItemActionBehavior.Show(self: Object)
    UIUtil:OpenUI(self._UI, OPEN_TWEENINFO, true)
end

function ItemActionBehavior.Hide(self: Object)
    UIUtil:CloseUI(self._UI, CLOSE_TWEENINFO)
end

return ItemActionBehavior :: Module
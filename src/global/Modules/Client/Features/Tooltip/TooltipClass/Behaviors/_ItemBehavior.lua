--[=[
    @class ItemBehavior
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

-- [ Constants ] --
--local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
--local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

-- [ Module Table ] --
local ItemBehavior = {}
ItemBehavior.__index = ItemBehavior

-- [ Types ] --
type ItemTooltipUI = typeof(PlayerGui.Tooltips.ItemTooltipUI)
type Behavior = TooltipClassTypes.Behavior
type Config = TooltipClassTypes.Config
type Info = TooltipClassTypes.Info
type Context = {
    UI: ItemTooltipUI,
    DestroySignal: Signal.Signal<nil>
}
export type ObjectData = {
    _UI: ItemTooltipUI,
    _Cbs: {},
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
function ItemBehavior.new(context: Context): Object
    local self = setmetatable({} :: any, ItemBehavior) :: Object

    self._UI = context.UI
    self._Cbs = {}
    self._DestroySignal = context.DestroySignal

    return self
end

function ItemBehavior.UpdateUI(self: Object, info: Info)
    local ItemData = info.ItemData
    local Config = ItemDataUtil:GetConfig(ItemData.Type)
    
    local ItemName = ItemData.Name
    local Rarity = Config[ItemName].Rarity

    self._UI.Container.Header.Container.ItemName.Text = ItemName
    self._UI.Container.Header.Container.Rarity.Text = Rarity
end

function ItemBehavior.UpdateCbs(self: Object, cbs: {})
    self._Cbs = cbs
end

function ItemBehavior.Show(self: Object)
    UIUtil:ForceUIOpen(self._UI, true)
end

function ItemBehavior.Hide(self: Object)
    UIUtil:ForceUIClose(self._UI)
end

return ItemBehavior :: Module
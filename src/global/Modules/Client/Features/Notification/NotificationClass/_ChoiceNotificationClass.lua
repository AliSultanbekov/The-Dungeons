--[=[
    @class ChoiceNotificationClass
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local Types = require("../_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local AssetProvider = require("AssetProvider")
local UIUtil = require("UIUtil")
local ButtonUtil = require("ButtonUtil")
local Signal = require("Signal")
local Maid = require("Maid")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

-- [ Module Table ] --
local ChoiceNotificationClass = {}
ChoiceNotificationClass.__index = ChoiceNotificationClass

-- [ Types ] --
type ChoiceNotificationInfo = Types.ChoiceNotificationInfo
type ChoiceNotificationUI = typeof(ReplicatedStorage.Assets.UIs.Notification.ChoiceNotificationUI)
export type ObjectData = {
    _Info: ChoiceNotificationInfo,
    _UI: ChoiceNotificationUI,
    _Destroying: boolean,
    _Maid: Maid.Maid,

    InteractionSignal: Signal.Signal<nil>,
}
export type Object = ObjectData & Module
export type Module = typeof(ChoiceNotificationClass)

-- [ Private Functions ] --
function ChoiceNotificationClass._CreateUI(self: Object): ChoiceNotificationUI
    local ChoiceNotificationUI = AssetProvider:Get("UIs/Notification/ChoiceNotificationUI") :: ChoiceNotificationUI
    UIUtil:ForceUIClose(ChoiceNotificationUI)
    ChoiceNotificationUI.Parent = PlayerGui.Misc
    ChoiceNotificationUI.Container.InfoText.Text = self._Info.InfoText

    local Choice1Button = ChoiceNotificationUI.Container.Choices.Choice1
    local Choice2Button = ChoiceNotificationUI.Container.Choices.Choice2
    Choice1Button.ChoiceText.Text = self._Info.Button1Text
    Choice2Button.ChoiceText.Text = self._Info.Button2Text

    ButtonUtil:Hook(Choice1Button, nil, nil, function()
        if self._Destroying then
            return
        end

        self.InteractionSignal:Fire()

        if self._Info.Button1Cb then
            self._Info.Button1Cb()
        end
    end)

    ButtonUtil:Hook(Choice2Button, nil, nil, function()
        if self._Destroying then
            return
        end

        self.InteractionSignal:Fire()

        if self._Info.Button2Cb then
            self._Info.Button2Cb()
        end
    end)

    return ChoiceNotificationUI
end

-- [ Public Functions ] --
function ChoiceNotificationClass.new(info: ChoiceNotificationInfo): Object
    local self = setmetatable({} :: any, ChoiceNotificationClass) :: Object
    
    self._Info = info
    self._UI = self:_CreateUI()
    self._Destroying = false
    self._Maid = Maid.new()

    self.InteractionSignal = Signal.new()

    self._Maid:Add(self._UI)

    UIUtil:OpenUI(self._UI, OPEN_TWEENINFO, true)

    return self
end

function ChoiceNotificationClass.Destroy(self: Object)
    self._Destroying = true

    UIUtil:CloseUI(self._UI, CLOSE_TWEENINFO, true, function() self._Maid:DoCleaning() end)
end

return ChoiceNotificationClass :: Module
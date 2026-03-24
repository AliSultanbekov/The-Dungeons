--[=[
    @class UIManager
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local UIConstants = require("./_UIConstants")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Promise = require("Promise")
local Signal = require("Signal")
local TopicConstantsClient = require("TopicConstantsClient")
local UIUtil = require("UIUtil")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

-- [ Module Table ] --
local UIManager = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EventBus: typeof(require("EventBus")),

    _Screens: {[string]: ScreenGui },
    _UIs: { [string]: Frame },
    _UIComponents: { [string]: { [string]: GuiObject }},
    _OpenUIs: { [string]: boolean },
    _UIReady: Promise.Promise<nil>,
    _Conns: { Signal.Connection<any> }
}

export type Module = typeof(UIManager) & ModuleData

-- [ Private Functions ] --
function UIManager._RegisterUI(self: Module, uiName: string)
    table.insert(self._Conns, self._EventBus:Subscribe(TopicConstantsClient.UI.Open(uiName), function(packet: any)
        self:Open(uiName)
    end))

    table.insert(self._Conns, self._EventBus:Subscribe(TopicConstantsClient.UI.Close(uiName), function(packet: any)
        self:Close(uiName)
    end))

    table.insert(self._Conns, self._EventBus:Subscribe(TopicConstantsClient.UI.Toggle(uiName), function(packet: any)
        self:Toggle(uiName)
    end))
end

function UIManager._SetupUIs(self: Module)
    for _, screenName in UIConstants.Screens do
        local ScreenInstance = PlayerGui:WaitForChild(screenName)

        self._Screens[screenName] = ScreenInstance

        for _, uiInstance in ScreenInstance:GetChildren() do
            if not uiInstance:IsA("Frame") then
                continue
            end

            self._UIs[uiInstance.Name] = uiInstance
            self._UIComponents[uiInstance.Name] = {}

            for _, instance_2 in uiInstance:GetDescendants() do
                local Tags = instance_2:GetTags()
                
                for _, tag: string in Tags do
                    if tag:find("UIComponent") then
                        self._UIComponents[uiInstance.Name][tag:split("UIComponent_")[2]] = instance_2
                    end
                end
            end

            self:_RegisterUI(uiInstance.Name)
            UIUtil:ForceUIClose(uiInstance)
        end
    end

    self._UIReady:Resolve()
end

-- [ Public Functions ] --
function UIManager.CloseAllExclusive(self: Module)
    for uiName, _ in self._OpenUIs do
        local UIGroup = UIConstants.UINameToGroup[uiName]

        if UIGroup == "Exclusive" then
            self:Close(uiName)
        end
    end
end

function UIManager.Toggle(self: Module, uiName: string)
    if self._OpenUIs[uiName] then
        self:Close(uiName)
    else
        self:Open(uiName)
    end
end

function UIManager.Open(self: Module, uiName: string)
    local UIGroup = UIConstants.UINameToGroup[uiName]

    if UIGroup == "Exclusive" then
        self:CloseAllExclusive()
    end

    self._OpenUIs[uiName] = true

    local UI = self:GetUI(uiName)

    UIUtil:OpenUI(UI, OPEN_TWEENINFO, true)

    self._EventBus:Publish(TopicConstantsClient.UI.OpenedAny)
end

function UIManager.Close(self: Module, uiName: string)
    self._OpenUIs[uiName] = nil

    local UI = self:GetUI(uiName)

    UIUtil:CloseUI(UI, CLOSE_TWEENINFO, true)

    self._EventBus:Publish(TopicConstantsClient.UI.ClosedAny)
end

function UIManager.GetUIComponent(self: Module, uiName: string, uiComponentName: string)
    return self._UIComponents[uiName][uiComponentName]
end

function UIManager.GetUI(self: Module, uiName: string)
    return self._UIs[uiName]
end

function UIManager.GetScreen(self: Module, screenName: string)
    return self._Screens[screenName]
end

function UIManager.UIReady(self: Module)
    return self._UIReady
end

function UIManager.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EventBus = self._ServiceBag:GetService(require("EventBus"))

    self._Screens = {}
    self._UIs = {}
    self._UIComponents = {}
    self._OpenUIs = {}
    self._UIReady = Promise.new()
    self._Conns = {}
end

function UIManager.Start(self: Module)
    task.spawn(function()
        self:_SetupUIs()
    end)
end

return UIManager :: Module
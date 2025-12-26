--[=[
    @class UIController
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- [ Imports ] --
local UIConstants = require("./Constants/_UIConstants")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Promise = require("Promise")
local TopicConstants = require("TopicConstants")
local Singal = require("Signal")
local UIUtil = require("UIUtil")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local UIController = {}

-- [ Types ] --
type UIs = typeof(StarterGui.UIs)

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EventBusClient: typeof(require("EventBusClient")),

    _Screens: { [string]: UIs },
    _UIs: { [string]: Instance },
    _UIComponents: { [string]: { [string]: Instance } },

    _OpenUIs: { [string]: boolean },
    _Conns: { Singal.Connection<any> },
    _UIReady: Promise.Promise<nil>
}

export type Module = typeof(UIController) & ModuleData

-- [ Private Functions ] --
function UIController._PublishOnOpened(self: Module, uiName: string)
    self._EventBusClient:Publish(TopicConstants.UI.OpenedAny)
end

function UIController._PublishOnClosed(self: Module, uiName: string)
    self._EventBusClient:Publish(TopicConstants.UI.ClosedAny)
end

function UIController._SetupUIs(self: Module)
    for _, screenName in UIConstants.Screens do
        local Screen = Player.PlayerGui:WaitForChild(screenName)

        self._Screens[screenName] = Screen

        for _, instance in Screen:GetChildren() do
            if not instance:IsA("Frame") then
                return
            end

            self._UIs[instance.Name] = instance
            self._UIComponents[instance.Name] = {}

            for _, instance_2 in instance:GetDescendants() do
                local Tags = instance_2:GetTags()
                
                for _, tag: string in Tags do
                    if tag:find("UIComponent") then
                        self._UIComponents[instance.Name][tag:split("UIComponent_")[2]] = instance_2
                    end
                end
            end
        end
    end

    self._UIReady:Resolve()
end

function UIController._CloseAllOpenUIs(self: Module)
    for uiName, _ in self._OpenUIs do
        self:Close(uiName)
    end
end

-- [ Public Functions ] --
function UIController.Open(self: Module, uiName: string)
    local UI = self:GetUI(uiName)

    self:_CloseAllOpenUIs()

    self._OpenUIs[uiName] = true

    self:_PublishOnOpened(uiName)

    UIUtil:OpenUI(UI, OPEN_TWEENINFO, true)
end

function UIController.Close(self: Module, uiName: string)
    local UI = self:GetUI(uiName)

    self._OpenUIs[uiName] = nil
    
    self:_PublishOnClosed(uiName)

    UIUtil:CloseUI(UI, CLOSE_TWEENINFO, true)
end

function UIController.Toggle(self: Module, uiName: string)
    if self._OpenUIs[uiName] then
        self:Close(uiName)
    else
        self:Open(uiName)
    end
end

function UIController.RegisterUI(self: Module, uiName: string)
    table.insert(self._Conns, self._EventBusClient:Subscribe(TopicConstants.UI.Open(uiName), function()
        self:Open(uiName)
    end))

    table.insert(self._Conns, self._EventBusClient:Subscribe(TopicConstants.UI.Close(uiName), function()
        self:Close(uiName)
    end))

    table.insert(self._Conns, self._EventBusClient:Subscribe(TopicConstants.UI.Toggle(uiName), function()
        self:Toggle(uiName)
    end))
end

function UIController.GetUIComponent(self: Module, uiName: string, uiComponentName: string)
    return self._UIComponents[uiName][uiComponentName]
end

function UIController.GetUI(self: Module, uiName: string)
    return self._Screens["UIs"][uiName]
end

function UIController.GetScreen(self: Module, screenName: string)
    return self._Screens[screenName]
end

function UIController.UIReady(self: Module)
    return self._UIReady
end

function UIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EventBusClient = self._ServiceBag:GetService(require("EventBusClient"))

    self._Screens = {} -- Key: ScreenName Value: Instance
    self._UIs = {} -- Key: UIName Value: Instance
    self._UIComponents = {} --Key: UIName Value: { Key: ComponentName Value: Instance }

    self._OpenUIs = {}
    self._Conns = {}
    self._UIReady = Promise.new()
end

function UIController.Start(self: Module)
    task.spawn(function()
        self:_SetupUIs()
    end)
end

return UIController :: Module
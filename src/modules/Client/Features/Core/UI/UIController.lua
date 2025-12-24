--[=[
    @class UIController
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local CoreUIConstants = require("./Constants/CoreUIConstants")

-- [ Require ] --
local RbxRequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Promise = require("Promise")
local UIUtil = require("UIUtil")
local Signal = require("Signal")
local TopicConstants = require("TopicConstants")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --
local Player = Players.LocalPlayer
local Screens = CoreUIConstants.Screens
local FactoriesFolder = script.Parent.Factories

-- [ Module Table ] --
local UIController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EventBusClient: typeof(require("EventBusClient")),
    
    _ScreenGuis: { [string]: ScreenGui },
    _OpenUIs: {
        [GuiObject]: unknown,
    },
    _MainUINameToRefs: {},
    _IntentConns: { Signal.Connection<any> },

    _UIReadyPromise: Promise.Promise<any>,
}

export type Module = typeof(UIController) & ModuleData

-- [ Private Functions ] --
local function _GetUI(self: Module, ui: GuiObject | string): GuiObject
    if type(ui) == "string" then
        return self._MainUINameToRefs[ui][ui]
    else
        return ui
    end
end

function _PublishOnOpened(self: Module, uiName: string)
    self._EventBusClient:Publish(TopicConstants.UI.OpenedAny)
end

function _PublishOnClosed(self: Module, uiName: string)
    self._EventBusClient:Publish(TopicConstants.UI.ClosedAny)
end

-- [ Public Functions ] --
function UIController.GetScreen(self: Module, screenName: string)
    return self._ScreenGuis[screenName]
end

function UIController.IsUIOpen(self: Module, uiOrName: GuiObject | string)
    local UI = _GetUI(self, uiOrName)
    
    if self._OpenUIs[UI] then
        return true
    else
        return false
    end
end

function UIController.ForceClose(self: Module, uiOrName: GuiObject | string)
    local UI = _GetUI(self, uiOrName)
    UIUtil:ForceUIClose(UI)
end

function UIController.ForceOpen(self: Module, uiOrName: GuiObject | string)
    local UI = _GetUI(self, uiOrName)
    UIUtil:ForceUIOpen(UI, true)
end

function UIController.Toggle(self: Module, uiOrName: GuiObject | string)
    local UI = _GetUI(self, uiOrName)

    if self._OpenUIs[UI] then
        self:Close(UI)
    else
        self:Open(UI)
    end
end

function UIController.CloseOpenUIs(self: Module)
    for ui in self._OpenUIs do
        UIUtil:CloseUI(ui, OPEN_TWEENINFO, true, function()
            self._EventBusClient:Publish(TopicConstants.UI.AutoClosed(ui.Name))
        end)
    end
end

function UIController.Open(self: Module, uiOrName: GuiObject | string)
    local UI = _GetUI(self, uiOrName)

    _PublishOnOpened(self, UI.Name)

    self:CloseOpenUIs()

    self._OpenUIs[UI] = true

    UIUtil:OpenUI(UI, OPEN_TWEENINFO, true)
end

function UIController.Close(self: Module, uiOrName: GuiObject | string)
    local UI = _GetUI(self, uiOrName)

    _PublishOnClosed(self, UI.Name)

    self._OpenUIs[UI] = nil

    UIUtil:CloseUI(UI, CLOSE_TWEENINFO, true)
end

function UIController.GetRefs(self: Module, key: string)
    return self._MainUINameToRefs[key]
end

function UIController.RegisterUI(self: Module, uiName: string)
    table.insert(self._IntentConns, self._EventBusClient:Subscribe(TopicConstants.UI.Open(uiName), function()
        self:Open(uiName)
    end))

    table.insert(self._IntentConns, self._EventBusClient:Subscribe(TopicConstants.UI.Close(uiName), function()
        print("Closeee")
        self:Close(uiName)
    end))

    table.insert(self._IntentConns, self._EventBusClient:Subscribe(TopicConstants.UI.Toggle(uiName), function()
        self:Toggle(uiName)
    end))
end

function UIController.InitUIs(self: Module)
    local PlayerGui = Player:WaitForChild("PlayerGui")

    for _, screenName in Screens do
        self._ScreenGuis[screenName] = PlayerGui:WaitForChild(screenName)
    end

    for _, Instance in FactoriesFolder:GetChildren() do
        if Instance.Name == "loader" then
            continue
        end

        local Factory = RbxRequire(Instance)

        local Success, Result = pcall(function()
            return Factory:ProduceRefs(self._ScreenGuis)
        end)

        if not Success then
            warn(`[UIController] Failed to produce refs for {Instance.Name}: {Result}`)
            continue
        end

        self._MainUINameToRefs[Factory.UIName] = Result

        self:RegisterUI(Factory.UIName)

        --self:ForceClose(self._MainUINameToRefs[Factory.UIName][Factory.UIName])
    end

    self._UIReadyPromise:Resolve(self._MainUINameToRefs)
end

function UIController.Ready(self: Module)
    return self._UIReadyPromise
end

function UIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EventBusClient = self._ServiceBag:GetService(require("EventBusClient"))

    self._ScreenGuis = {}
    self._OpenUIs = {}
    self._MainUINameToRefs = {}
    self._IntentConns = {}

    self._UIReadyPromise = Promise.new()
end 

function UIController.Start(self: Module)
    task.spawn(function()
        self:InitUIs()
    end)
end

return UIController :: Module
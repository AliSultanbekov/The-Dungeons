--[=[
    @class InventoryUIController
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local CreateItemUIObject = require("./ItemUIClass/_CreateItemUIObject")
local InventoryConstants = require("./Constants/_InventoryConstants")
local GetGroupKey = require("@self/_GetGroupKey")
local UIGridClass = require("./_UIGridClass")
local KeyMap = require("@self/_KeyMap")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local TopicConstants = require("TopicConstants")
local AssetProvider = require("AssetProvider")
local ButtonUtil = require("ButtonUtil")
local ObjectPool = require("ObjectPool")
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local UIAnimUtil = require("UIAnimUtil")

-- [ Constants ] --

-- [ Variables ] --
local UIPool = ObjectPool.new()
UIPool:AddKey(
    "ItemUI",
    function()
        return AssetProvider:Get("UIs/Inventory/ItemUI")
    end,
    function(obj: any)
        obj.Parent = nil
    end
)
UIPool:ForceConstruct("ItemUI", 10)

-- [ Module Table ] --
local InventoryUIController = {}                                                                                                                                                                                          

-- [ Types ] --
type ItemUIObject = CreateItemUIObject.ItemUIObject
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)
type ItemData = ItemTypes.ItemData
type GroupKey = string

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIController: typeof(require("UIController")),
    _UserInputController: typeof(require("UserInputController")),
    _EventBusClient: typeof(require("EventBusClient")),
    _CameraController: typeof(require("CameraController")),

    _GridObjects: {[string]: UIGridClass.Object},
    _ItemUIObjects: { [GroupKey]: ItemUIObject },

    _CurrentPage: string
}

export type Module = typeof(InventoryUIController) & ModuleData

-- [ Private Functions ] --
function InventoryUIController._ShiftUIToRight(self: Module)
    UIAnimUtil:AnimateToPosition(self._UIController:GetUI("InventoryUI"), UDim2.new(0.7, 0, 0.5, 0), TweenInfo.new(0.1))
end

function InventoryUIController._ShiftUIToMiddle(self: Module)
    UIAnimUtil:AnimateToPosition(self._UIController:GetUI("InventoryUI"), UDim2.new(0.5, 0, 0.5, 0), TweenInfo.new(0.1))
end

function InventoryUIController._OnPageSwitch(self: Module, newPageName: string)
    if newPageName == "Equipment" then
        self:_ShiftUIToRight()
        self._CameraController:RunPreset("InventoryEquipment")
        self._UserInputController:ToggleControls(false)
    else
        self:_ShiftUIToMiddle()
        self._CameraController:RunPreset("Reset")
        self._UserInputController:ToggleControls(true)
    end
end

function InventoryUIController._TrySwitchingToItemsPage(self: Module): boolean
    if self._CurrentPage ~= "Items" then
        local SwitchComplete = self:SwitchPage("Items")

        if not SwitchComplete then
            return false
        end
    end

    return true
end

-- [ Public Functions ] --
function InventoryUIController.SwitchPage(self: Module, pageName: string): boolean
    if self._CurrentPage == pageName then
        return false
    end

    local Pages = self._UIController:GetUIComponent("InventoryUI", "Pages")
    local CurrentPage = Pages:FindFirstChild(self._CurrentPage) :: Frame
    local NextPage = Pages:FindFirstChild(pageName) :: Frame

    if self._CameraController:GetState() == "Busy" then
        return false
    end

    self:_OnPageSwitch(pageName)

    CurrentPage.Visible = false
    NextPage.Visible = true

    self._CurrentPage = pageName

    return true
end

function InventoryUIController.AddItem(self: Module, itemData: ItemData)
    local GroupKey = GetGroupKey(itemData)

    local SectionName = InventoryConstants.ItemTypeToSections[itemData.Type]
    local PageName = InventoryConstants.SectionToPage[SectionName]
    local GridObject = self._GridObjects[PageName]
    local ItemUIObject = self._ItemUIObjects[GroupKey]

    if not ItemUIObject then
        local ItemUI = UIPool:Get("ItemUI")
        GridObject:AddElement(SectionName, ItemUI)
        ItemUIObject = CreateItemUIObject(ItemUI, itemData)

        self._ItemUIObjects[GroupKey] = ItemUIObject
    else
        ItemUIObject:AddItemData(itemData)
    end
end

function InventoryUIController.RemoveItem(self: Module, itemData: ItemData)
    local GroupKey = GetGroupKey(itemData)

    local SectionName = InventoryConstants.ItemTypeToSections[itemData.Type]
    local PageName = InventoryConstants.SectionToPage[SectionName]
    local GridObject = self._GridObjects[PageName]
    local ItemUIObject = self._ItemUIObjects[GroupKey]

    if not ItemUIObject then
        return
    end

    ItemUIObject:RemoveItemData(itemData)
    GridObject:RemoveElement(SectionName, ItemUIObject:GetUI())

    if ItemUIObject:IsEmpty() then
        self._ItemUIObjects[GroupKey] = nil
    end
end

function InventoryUIController.Close(self: Module)
    if not self:_TrySwitchingToItemsPage() then
        return
    end
    
    self._EventBusClient:Publish(TopicConstants.UI.Close("InventoryUI"))
end

function InventoryUIController.Toggle(self: Module)
    if not self:_TrySwitchingToItemsPage() then
        return
    end

    self._EventBusClient:Publish(TopicConstants.UI.Toggle("InventoryUI"))
end

function InventoryUIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIController = self._ServiceBag:GetService(require("UIController"))
    self._UserInputController = self._ServiceBag:GetService(require("UserInputController"))
    self._EventBusClient = self._ServiceBag:GetService(require("EventBusClient"))
    self._CameraController = self._ServiceBag:GetService(require("CameraController"))

    self._GridObjects = {}
    self._ItemUIObjects = {}

    self._CurrentPage = "Items"
end

function InventoryUIController.Start(self: Module)
    self._UIController:UIReady():Then(function()
        local Actions = KeyMap.Actions
        local KeyMaps = KeyMap.KeyMaps
        local CloseButton = self._UIController:GetUIComponent("InventoryUI", "Close") :: GuiButton
        local PageButtons = self._UIController:GetUIComponent("InventoryUI", "PageButtons")

        local function setupGrids()
            for pageName, sectionsData in InventoryConstants.Pages do

                local GridUI = self._UIController:GetUIComponent("InventoryUI", string.format("%sGrid", pageName)) :: ScrollingFrame
                print(self._UIController)

                local UIGridObject = UIGridClass.new(GridUI)

                for _, sectionName in sectionsData do
                    UIGridObject:CreateSection(sectionName)
                end

                self._GridObjects[pageName] = UIGridObject
            end
        end

        local function hookUIs()
            ButtonUtil:Hook(CloseButton, function()
                self:Close()
            end)
    
            self._UserInputController:RegisterKeymapAction(
                Actions.TOGGLE_INVENTORY_UI,
                KeyMaps[Actions.TOGGLE_INVENTORY_UI],
                function(packet)
                    if packet.InputState ~= Enum.UserInputState.Begin then
                        return
                    end
    
                    self:Toggle()
                end
            )

            for _, instance in PageButtons:GetChildren() do
                if not instance:IsA("GuiButton") then
                    continue
                end

                ButtonUtil:Hook(instance, function()
                    self:SwitchPage(instance.Name)
                end)
            end
        end

        setupGrids()
        hookUIs()

        self:AddItem({
            ID = "3",
            Type = "Weapons",
            Name = "Sword",
        })
    end)
end

return InventoryUIController :: Module
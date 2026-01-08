--[=[
    @class InventoryUIController
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local InventoryConstants = require("./Constants/_InventoryConstants")
local EquipmentDisplayClass = require("@self/_EquipmentDisplayClass")
local GetGroupKey = require("@self/_GetGroupKey")
local UIGridClass = require("@self/_UIGridClass")
local KeyMap = require("@self/_KeyMap")
local ItemUIClassBuilder = require("./ItemUIClass/_ItemUIClassBuilder")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local TopicConstantsClient = require("TopicConstantsClient")
local AssetProvider = require("AssetProvider")
local ButtonUtil = require("ButtonUtil")
local ObjectPool = require("ObjectPool")
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local UIAnimUtil = require("UIAnimUtil")
local ItemConstants = require("ItemConstants")

-- [ Constants ] --
local DELETE_MODE_OFF_COLOR = Color3.fromRGB(255, 255, 255)
local DELETE_MODE_ON_COLOR = Color3.fromRGB(255, 56, 56)

-- [ Variables ] --

-- [ Module Table ] --
local InventoryUIController = {}                                                                                                                                                                                          

-- [ Types ] --
type ItemUIObject = ItemUIClassBuilder.ItemUIObject
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)
type StackableItemData = ItemTypes.StackableItemData
type UniqueItemData = ItemTypes.UniqueItemData
type ItemData = ItemTypes.ItemData
type GroupKey = string

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIController: typeof(require("UIController")),
    _UserInputController: typeof(require("UserInputController")),
    _EventBusClient: typeof(require("EventBusClient")),
    _CameraController: typeof(require("CameraController")),
    _TooltipController: typeof(require("TooltipController")),
    _NotificationController: typeof(require("NotificationController")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),

    _UIPool: ObjectPool.Object<GuiObject>,

    _GridObjects: {[string]: UIGridClass.Object},
    _ItemUIObjects: { [GroupKey]: ItemUIObject },
    _ItemIDToGroupKey: { [string]: GroupKey },
    _ItemUIToGroupKey: { [GuiObject]: GroupKey },
    _CurrentPage: string,
    _DeleteMode: boolean,
    _ItemsDataToDelete: { [string]: ItemData },
    _MarkedItemUIObjects: { [GroupKey]: ItemUIObject },

    _EquipmentDisplayObject: EquipmentDisplayClass.Object,
}

export type Module = typeof(InventoryUIController) & ModuleData

-- [ Private Functions ] --
function InventoryUIController._ShiftUIToRight(self: Module)
    UIAnimUtil:AnimateToPosition(self._UIController:GetUI("InventoryUI"), UDim2.new(0.7, 0, 0.5, 0), TweenInfo.new(0.1))
end

function InventoryUIController._ShiftUIToMiddle(self: Module)
    UIAnimUtil:AnimateToPosition(self._UIController:GetUI("InventoryUI"), UDim2.new(0.5, 0, 0.5, 0), TweenInfo.new(0.1))
end

function InventoryUIController._HideTooltips(self: Module)
    self._TooltipController:Hide("ItemTooltip")
    self._TooltipController:Hide("ItemActionTooltip")
end

function InventoryUIController._OnPageSwitch(self: Module, newPageName: string)
    if newPageName == "Equipment" then
        self:_ShiftUIToRight()
        self._CameraController:RunPreset("InventoryEquipment")
        self._UserInputController:ToggleControls(false)
        self._EquipmentDisplayObject:Show()
    else
        self:_ShiftUIToMiddle()
        if self._CameraController:GetCurrentPreset() == "InventoryEquipment" then
            self._CameraController:RunPreset("Reset")
            self._UserInputController:ToggleControls(true)
            self._EquipmentDisplayObject:Hide()
        end
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

function InventoryUIController._ClearMarkedItemUIObjects(self: Module)
    for _, itemUIObject in self._MarkedItemUIObjects do
        itemUIObject:ClearMarked()
    end

    self._MarkedItemUIObjects = {}
end

-- [ Public Functions ] --
function InventoryUIController.ToggleDeleteMode(self: Module)
    local DeleteModeButton = self._UIController:GetUIComponent("InventoryUI", "DeleteMode")
    local Icon = DeleteModeButton:FindFirstChild("Icon") :: ImageLabel

    self:_HideTooltips()

    if self._DeleteMode == false then
        self._DeleteMode = true
        Icon.ImageColor3 = DELETE_MODE_ON_COLOR
    elseif self._DeleteMode == true then
        self._DeleteMode = false
        self:_ClearMarkedItemUIObjects()

        if next(self._ItemsDataToDelete) ~= nil then
            self._NotificationController:Notify("ChoiceNotification", { 
                InfoText = "Are you sure you want to delete selected items?", 
                Button1Text = "No", 
                Button2Text = "Yes",
                Button1Cb = function()
                    self._ItemsDataToDelete = {}
                end,
                Button2Cb = function()
                    local ItemsDataToDelete = self._ItemsDataToDelete
                    self._ItemsDataToDelete = {}
                    self._InventoryServiceClient:RemoveItems(ItemsDataToDelete)
                end
            })
        end

        Icon.ImageColor3 = DELETE_MODE_OFF_COLOR
    end
end

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

    self:_HideTooltips()
    self:_OnPageSwitch(pageName)

    CurrentPage.Visible = false
    NextPage.Visible = true

    self._CurrentPage = pageName

    return true
end

function InventoryUIController.UpdateItem(self: Module, itemData: ItemData)
    local GroupKey = GetGroupKey(itemData)
    local OldGroupKey = self._ItemIDToGroupKey[itemData.ID]
    local OldItemUIObject = self._ItemUIObjects[OldGroupKey]

    if GroupKey == OldGroupKey then
        warn("[InventoryUIController] Tried to update item, but data group has not changed: " .. tostring(itemData.Name))
        return
    end

    local OldItemData = OldItemUIObject:GetItemData(itemData.ID)

    self:RemoveItem(OldItemData)
    self:AddItem(itemData)
end

function InventoryUIController.AddItem(self: Module, itemData: ItemData)
    local GroupKey = GetGroupKey(itemData)
    local PageName = InventoryConstants.ItemTypeToPage[itemData.Type]
    local GridObject = self._GridObjects[PageName]
    local ItemUIObject = self._ItemUIObjects[GroupKey]

    if not ItemUIObject then
        local ItemUI = self._UIPool:Get("ItemUI")
        local NewItemUIObject = ItemUIClassBuilder:Build(ItemUI, itemData)
        self._ItemUIObjects[GroupKey] = NewItemUIObject
        self._ItemUIToGroupKey[ItemUI] = GroupKey

        GridObject:AddElement(ItemUI)
    else
        ItemUIObject:AddItemData(itemData)
    end

    self._ItemIDToGroupKey[itemData.ID] = GroupKey
end

function InventoryUIController.RemoveItem(self: Module, itemData: ItemData)
    local GroupKey = GetGroupKey(itemData)
    local PageName = InventoryConstants.ItemTypeToPage[itemData.Type]
    local GridObject = self._GridObjects[PageName]
    local ItemUIObject = self._ItemUIObjects[GroupKey]
    local StorageType = ItemConstants.ItemTypeToStorageType[itemData.Type]

    if not ItemUIObject then
        warn("[InventoryUIController] Tried to remove item that does not exist in UI: " .. tostring(itemData.Name))
        return
    end

    if ItemUIObject:IsEmpty() then
        warn("[InventoryUIController] Tried to remove item that is already empty: " .. tostring(itemData.Name))
        return
    end

    local function handleUnqiue()
        self._ItemIDToGroupKey[itemData.ID] = nil
    end

    --[[local function handleStackable()
        
    end]]

    ItemUIObject:RemoveItemData(itemData)

    if ItemUIObject:IsEmpty() then
        local ItemUI = ItemUIObject:GetUI()
        self._ItemUIObjects[GroupKey] = nil
        self._ItemUIToGroupKey[ItemUI] = nil

        GridObject:RemoveElement(ItemUI)
        self._UIPool:Return("ItemUI", ItemUI)
    end

    if StorageType == "Unqiue" then
        handleUnqiue()
    end
end

function InventoryUIController.Close(self: Module)
    if not self:_TrySwitchingToItemsPage() then
        return
    end
    
    self:_HideTooltips()
    self._EventBusClient:Publish(TopicConstantsClient.UI.Close("InventoryUI"))
end

function InventoryUIController.Toggle(self: Module)
    if not self:_TrySwitchingToItemsPage() then
        return
    end
    
    self:_HideTooltips()
    self._EventBusClient:Publish(TopicConstantsClient.UI.Toggle("InventoryUI"))
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
    self._TooltipController = self._ServiceBag:GetService(require("TooltipController"))
    self._NotificationController = self._ServiceBag:GetService(require("NotificationController"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))

    self._UIPool = ObjectPool.new()

    self._GridObjects = {}
    self._ItemUIObjects = {}
    self._ItemIDToGroupKey = {}
    self._ItemUIToGroupKey = {}
    self._CurrentPage = "Items"
    self._DeleteMode = false
    self._ItemsDataToDelete = {}
    self._MarkedItemUIObjects = {}
end

function InventoryUIController.Start(self: Module)
    self._UIController:UIReady():Then(function()
        self._EquipmentDisplayObject = EquipmentDisplayClass.new()

        local Actions = KeyMap.Actions
        local KeyMaps = KeyMap.KeyMaps
        local CloseButton = self._UIController:GetUIComponent("InventoryUI", "Close") :: GuiButton
        local PageButtons = self._UIController:GetUIComponent("InventoryUI", "PageButtons")
        local ActionButtons = self._UIController:GetUIComponent("InventoryUI", "ActionButtons")

        local function setupUIPool()
            self._UIPool:AddKey(
                "ItemUI",
                function()
                    local UI = AssetProvider:Get("UIs/Inventory/ItemUI") :: ItemUI

                    local function onHover()
                        if self._DeleteMode then
                            return
                        end

                        local GroupKey = self._ItemUIToGroupKey[UI]
                        local ItemUIObject = self._ItemUIObjects[GroupKey]
                        local ItemData = ItemUIObject:GetItemData()
                        
                        if self._TooltipController:GetActive() ~= "ItemActionTooltip" then
                            self._TooltipController:UpdateUI("ItemTooltip", { ItemData = ItemData })
                            self._TooltipController:Show("ItemTooltip", true)
                        end
                    end

                    local function onUnhover()
                        if self._DeleteMode then
                            return
                        end

                        if self._TooltipController:GetActive() ~= "ItemActionTooltip" then
                            self._TooltipController:Hide("ItemTooltip")
                        end
                    end

                    local function onClick()
                        local GroupKey = self._ItemUIToGroupKey[UI]
                        local ItemUIObject = self._ItemUIObjects[GroupKey]

                        if ItemUIObject:MaxMarked() then
                            return
                        end

                        if self._DeleteMode then
                            local function handleUnique(itemData: UniqueItemData)
                                self._ItemsDataToDelete[itemData.ID] = itemData
                            end
    
                            local function handleStackable(itemData: StackableItemData)
                                itemData.Amount = 1

                                local ExistingItemDataToDelete  = self._ItemsDataToDelete[itemData.ID] :: StackableItemData
                                if ExistingItemDataToDelete then
                                    ExistingItemDataToDelete.Amount += itemData.Amount
                                else
                                    self._ItemsDataToDelete[itemData.ID] = itemData
                                end
                            end

                            local ItemData = ItemUIObject:GetItemData(nil, true)
                            local StorageType = ItemConstants.ItemTypeToStorageType[ItemData.Type]

                            if StorageType == "Unique" then
                                handleUnique(ItemData :: UniqueItemData)
                            elseif StorageType == "Stackable" then
                                handleStackable(ItemData :: StackableItemData)
                            end

                            ItemUIObject:Mark(ItemData)

                            if not self._MarkedItemUIObjects[GroupKey] then
                                self._MarkedItemUIObjects[GroupKey] = ItemUIObject
                            end
                        else
                            local ItemData = ItemUIObject:GetItemData()
                            local UIPosition = UI.AbsolutePosition + Vector2.new(UI.AbsoluteSize.X + 15, 0)

                            self._TooltipController:UpdateCbs("ItemActionTooltip", {
                                ["Equip"] = function()
                                    self._InventoryServiceClient:EquipItem(ItemData)
                                end,
                                ["Unequip"] = function()
                                    self._InventoryServiceClient:UnequipItem(ItemData)
                                end
                            })

                            self._TooltipController:UpdateUI("ItemActionTooltip", {
                                ItemData = ItemData
                            })
                            self._TooltipController:UpdatePosition("ItemActionTooltip", UDim2.new(0, UIPosition.X, 0, UIPosition.Y))
                            self._TooltipController:Show("ItemActionTooltip")
                        end
                    end

                    ButtonUtil:Hook(UI,
                        function()
                            onHover()
                        end,

                        function()
                            onUnhover()
                        end,

                        function()
                            onClick()
                        end
                    )

                    return UI
                end,
                function(obj: any)
                    obj.Parent = nil
                end
            )
            self._UIPool:ForceConstruct("ItemUI", 10)
        end

        local function setupGrids()
            for pageName, sectionsData in InventoryConstants.Pages do
                local GridUI = self._UIController:GetUIComponent("InventoryUI", string.format("%sGrid", pageName)) :: ScrollingFrame
                local UIGridObject = UIGridClass.new(GridUI)
                self._GridObjects[pageName] = UIGridObject
            end
        end

        local function hookUIs()
            ButtonUtil:Hook(CloseButton, nil, nil, function()
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

                ButtonUtil:Hook(instance, nil, nil, function()
                    self:SwitchPage(instance.Name)
                end)
            end

            for _, instance in ActionButtons:GetChildren() do
                if not instance:IsA("GuiButton") then
                    continue
                end

                ButtonUtil:Hook(instance, nil, nil, function()
                    if instance.Name == "DeleteMode" then
                        self:ToggleDeleteMode()
                    end
                end)
            end
        end

        local function processData()
            for _, itemData: ItemData in self._InventoryServiceClient:GetItemDatas() do
                self:AddItem(itemData)
            end
        end

        setupUIPool()
        setupGrids()
        hookUIs()
        processData()

        self._InventoryServiceClient.PublicSignals.ItemsAdded:Connect(function(itemDataMap)
            for _, itemData in itemDataMap do
                self:AddItem(itemData)
            end
        end)

        self._InventoryServiceClient.PublicSignals.ItemsRemoved:Connect(function(itemDataMap)
            for _, itemData in itemDataMap do
                print(itemData)
                self:RemoveItem(itemData)
            end
        end)

        self._InventoryServiceClient.PublicSignals.ItemUnequipped:Connect(function(itemData: ItemData)
            self:UpdateItem(itemData)
        end)

        self._InventoryServiceClient.PublicSignals.ItemEquipped:Connect(function(itemData: ItemData)
            self:UpdateItem(itemData)
        end)
    end)
end

return InventoryUIController :: Module
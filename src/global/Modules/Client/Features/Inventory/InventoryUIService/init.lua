--[=[
    @class InventoryUIService
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local InventoryConstants = require("./Constants/_InventoryConstants")
local EquipmentDisplayClass = require("@self/_EquipmentDisplayClass")
local GetGroupKey = require("@self/_GetGroupKey")
local UIGridClass = require("@self/_UIGridClass")
local Keybinds = require("@self/_Keybinds")
local ItemUIClassBuilder = require("@self/ItemUIClass/_ItemUIClassBuilder")

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
local InventoryUIService = {}                                                                                                                                                                                          

-- [ Types ] --
type ItemUIObject = ItemUIClassBuilder.ItemUIObject
type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)
type StackableItemData = ItemTypes.StackableItemData
type UniqueItemData = ItemTypes.UniqueItemData
type ItemData = ItemTypes.ItemData
type GroupKey = string

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIManager: typeof(require("UIManager")),
    _UserInputManager: typeof(require("UserInputManager")),
    _EventBus: typeof(require("EventBus")),
    _CameraManager: typeof(require("CameraManager")),
    _TooltipService: typeof(require("TooltipService")),
    _NotificationService: typeof(require("NotificationService")),
    _InventoryNetworkClient: typeof(require("InventoryNetworkClient")),

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

export type Module = typeof(InventoryUIService) & ModuleData

-- [ Private Functions ] --
function InventoryUIService._ShiftUIToRight(self: Module)
    UIAnimUtil:AnimateToPosition(self._UIManager:GetUI("InventoryUI"), UDim2.new(0.7, 0, 0.5, 0), TweenInfo.new(0.1))
end

function InventoryUIService._ShiftUIToMiddle(self: Module)
    UIAnimUtil:AnimateToPosition(self._UIManager:GetUI("InventoryUI"), UDim2.new(0.5, 0, 0.5, 0), TweenInfo.new(0.1))
end

function InventoryUIService._HideTooltips(self: Module)
    self._TooltipService:Hide("ItemTooltip")
    self._TooltipService:Hide("ItemActionTooltip")
end

function InventoryUIService._OnPageSwitch(self: Module, newPageName: string)
    if newPageName == "Equipment" then
        self:_ShiftUIToRight()
        self._CameraManager:RunPreset("InventoryEquipment")
        self._UserInputManager:ToggleControls(false)
        self._EquipmentDisplayObject:Show()
    else
        self:_ShiftUIToMiddle()
        if self._CameraManager:GetCurrentPreset() == "InventoryEquipment" then
            self._CameraManager:RunPreset("Reset")
            self._UserInputManager:ToggleControls(true)
            self._EquipmentDisplayObject:Hide()
        end
    end
end

function InventoryUIService._TrySwitchingToItemsPage(self: Module): boolean
    if self._CurrentPage ~= "Items" then
        local SwitchComplete = self:SwitchPage("Items")

        if not SwitchComplete then
            return false
        end
    end

    return true
end

function InventoryUIService._ClearMarkedItemUIObjects(self: Module)
    for _, itemUIObject in self._MarkedItemUIObjects do
        itemUIObject:ClearMarked()
    end

    self._MarkedItemUIObjects = {}
end

-- [ Public Functions ] --
function InventoryUIService.ToggleDeleteMode(self: Module)
    local DeleteModeButton = self._UIManager:GetUIComponent("InventoryUI", "DeleteMode")
    local Icon = DeleteModeButton:FindFirstChild("Icon") :: ImageLabel

    self:_HideTooltips()

    if self._DeleteMode == false then
        self._DeleteMode = true
        Icon.ImageColor3 = DELETE_MODE_ON_COLOR
    elseif self._DeleteMode == true then
        self._DeleteMode = false
        self:_ClearMarkedItemUIObjects()

        if next(self._ItemsDataToDelete) ~= nil then
            self._NotificationService:Notify("ChoiceNotification", { 
                InfoText = "Are you sure you want to delete selected items?",
                Button1Text = "No", 
                Button2Text = "Yes",
                Button1Cb = function()
                    self._ItemsDataToDelete = {}
                end,
                Button2Cb = function()
                    local ItemsDataToDelete = self._ItemsDataToDelete
                    self._ItemsDataToDelete = {}
                    self._InventoryNetworkClient:RemoveItems(ItemsDataToDelete)
                end
            })
        end

        Icon.ImageColor3 = DELETE_MODE_OFF_COLOR
    end
end

function InventoryUIService.SwitchPage(self: Module, pageName: string): boolean
    if self._CurrentPage == pageName then
        return false
    end

    local Pages = self._UIManager:GetUIComponent("InventoryUI", "Pages")
    local CurrentPage = Pages:FindFirstChild(self._CurrentPage) :: Frame
    local NextPage = Pages:FindFirstChild(pageName) :: Frame

    if self._CameraManager:GetState() == "Busy" then
        return false
    end

    self:_HideTooltips()
    self:_OnPageSwitch(pageName)

    CurrentPage.Visible = false
    NextPage.Visible = true

    self._CurrentPage = pageName

    return true
end

function InventoryUIService.UpdateItem(self: Module, itemData: ItemData)
    local GroupKey = GetGroupKey(itemData)
    local OldGroupKey = self._ItemIDToGroupKey[itemData.ID]
    local OldItemUIObject = self._ItemUIObjects[OldGroupKey]

    if GroupKey == OldGroupKey then
        warn("[InventoryUIService] Tried to update item, but data group has not changed: " .. tostring(itemData.Name))
        return
    end

    local OldItemData = OldItemUIObject:GetItemData(itemData.ID)

    self:RemoveItem(OldItemData)
    self:AddItem(itemData)
end

function InventoryUIService.AddItem(self: Module, itemData: ItemData)
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

function InventoryUIService.RemoveItem(self: Module, itemData: ItemData)
    local GroupKey = GetGroupKey(itemData)
    local PageName = InventoryConstants.ItemTypeToPage[itemData.Type]
    local GridObject = self._GridObjects[PageName]
    local ItemUIObject = self._ItemUIObjects[GroupKey]
    local StorageType = ItemConstants.ItemTypeToStorageType[itemData.Type]

    if not ItemUIObject then
        warn("[InventoryUIService] Tried to remove item that does not exist in UI: " .. tostring(itemData.Name))
        return
    end

    if ItemUIObject:IsEmpty() then
        warn("[InventoryUIService] Tried to remove item that is already empty: " .. tostring(itemData.Name))
        return
    end

    ItemUIObject:RemoveItemData(itemData)

    if ItemUIObject:IsEmpty() then
        local ItemUI = ItemUIObject:GetUI()
        self._ItemUIObjects[GroupKey] = nil
        self._ItemUIToGroupKey[ItemUI] = nil

        GridObject:RemoveElement(ItemUI)
        self._UIPool:Return("ItemUI", ItemUI)
    end

    if StorageType == "Unique" then
        self._ItemIDToGroupKey[itemData.ID] = nil
    end
end

function InventoryUIService.Close(self: Module)
    if not self:_TrySwitchingToItemsPage() then
        return
    end
    
    self:_HideTooltips()
    self._EventBus:Publish(TopicConstantsClient.UI.Close("InventoryUI"))
end

function InventoryUIService.Toggle(self: Module)
    if not self:_TrySwitchingToItemsPage() then
        return
    end
    
    self:_HideTooltips()
    self._EventBus:Publish(TopicConstantsClient.UI.Toggle("InventoryUI"))
end

function InventoryUIService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIManager = self._ServiceBag:GetService(require("UIManager"))
    self._UserInputManager = self._ServiceBag:GetService(require("UserInputManager"))
    self._EventBus = self._ServiceBag:GetService(require("EventBus"))
    self._CameraManager = self._ServiceBag:GetService(require("CameraManager"))
    self._TooltipService = self._ServiceBag:GetService(require("TooltipService"))
    self._NotificationService = self._ServiceBag:GetService(require("NotificationService"))
    self._InventoryNetworkClient = self._ServiceBag:GetService(require("InventoryNetworkClient"))

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

function InventoryUIService.Start(self: Module)
    self._UIManager:UIReady():Then(function()
        self._EquipmentDisplayObject = EquipmentDisplayClass.new()

        local Actions = Keybinds.Actions
        local KeyMaps = Keybinds.KeyMaps
        local CloseButton = self._UIManager:GetUIComponent("InventoryUI", "Close") :: GuiButton
        local PageButtons = self._UIManager:GetUIComponent("InventoryUI", "PageButtons")
        local ActionButtons = self._UIManager:GetUIComponent("InventoryUI", "ActionButtons")

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
                        
                        if self._TooltipService:GetActive() ~= "ItemActionTooltip" then
                            self._TooltipService:UpdateUI("ItemTooltip", { ItemData = ItemData })
                            self._TooltipService:Show("ItemTooltip", true)
                        end
                    end

                    local function onUnhover()
                        if self._DeleteMode then
                            return
                        end

                        if self._TooltipService:GetActive() ~= "ItemActionTooltip" then
                            self._TooltipService:Hide("ItemTooltip")
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

                            self._TooltipService:UpdateCbs("ItemActionTooltip", {
                                ["Equip"] = function()
                                    self._InventoryNetworkClient:EquipItem(ItemData)
                                end,
                                ["Unequip"] = function()
                                    self._InventoryNetworkClient:UnequipItem(ItemData)
                                end
                            })

                            self._TooltipService:UpdateUI("ItemActionTooltip", {
                                ItemData = ItemData
                            })
                            self._TooltipService:UpdatePosition("ItemActionTooltip", UDim2.new(0, UIPosition.X, 0, UIPosition.Y))
                            self._TooltipService:Show("ItemActionTooltip")
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
                local GridUI = self._UIManager:GetUIComponent("InventoryUI", string.format("%sGrid", pageName)) :: ScrollingFrame
                local UIGridObject = UIGridClass.new(GridUI)
                self._GridObjects[pageName] = UIGridObject
            end
        end

        local function hookUIs()
            ButtonUtil:Hook(CloseButton, nil, nil, function()
                self:Close()
            end)
    
            self._UserInputManager:RegisterKeymapAction(
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
            for _, itemData: ItemData in self._InventoryNetworkClient:GetItemsData() do
                self:AddItem(itemData)
            end
        end

        setupUIPool()
        setupGrids()
        hookUIs()
        processData()

        self._InventoryNetworkClient.RemoteEvents.ItemsAdded:Connect(function(itemsData)
            for _, itemData in itemsData do
                self:AddItem(itemData)
            end
        end)

        self._InventoryNetworkClient.RemoteEvents.ItemsRemoved:Connect(function(itemsData)
            for _, itemData in itemsData do
                print(itemData)
                self:RemoveItem(itemData)
            end
        end)

        self._InventoryNetworkClient.RemoteEvents.ItemUpdated:Connect(function(itemData: ItemData)
            self:UpdateItem(itemData)
        end)
    end)
end

return InventoryUIService :: Module
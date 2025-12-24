--[=[
    @class InventoryUIController
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local UIGridClass = require("./_UIGridClass")
local InventoryConstants = require("./Constants/_InventoryConstants")
local ItemUIClass = require("./ItemUIClass/_UniqueUIClass")
local KeyMap = require("@self/_KeyMap")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local InventoryUIFactory = require("InventoryUIFactory")
local ItemTypes = require("ItemTypes")
local ObjectPool = require("ObjectPool")
local AssetProvider = require("AssetProvider")
local ButtonUtil = require("ButtonUtil")
local TopicConstants = require("TopicConstants")

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
type ItemData = ItemTypes.ItemData
type GroupKey = string

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIController: typeof(require("UIController")),
    _UserInputController: typeof(require("UserInputController")),
    _EventBusClient: typeof(require("EventBusClient")),

    -- after runtime
    _TabUIGridObjects: {[string]: UIGridClass.Object},
    _ItemUIObjects: { [GroupKey]: any }
}

export type Module = typeof(InventoryUIController) & ModuleData

-- [ Private Functions ] --
function InventoryUIController.GetGroupKey(self: Module, itemData: ItemData): GroupKey
    return ""
end

function InventoryUIController.AddItem(self: Module, itemData: ItemData)
    local SectionName = InventoryConstants.ItemTypeToSections[itemData.Type]
    local TabName = InventoryConstants.SectionToTab[SectionName]
    local UIGridObject = self._TabUIGridObjects[TabName]
    local GroupKey = self:GetGroupKey(itemData)
    local ItemUIObject = self._ItemUIObjects[GroupKey]

    if ItemUIObject == nil then
        local ItemUI = UIPool:Get("ItemUI")
        UIGridObject:AddElement(SectionName, ItemUI)
        ItemUIObject = ItemUIClass.new(ItemUI)
    else
        
    end

    ItemUIObject:AddItemData(itemData)
end

function InventoryUIController.RemoveItem(self: Module, itemData: ItemData)
    
end

function InventoryUIController.Close(self: Module)
    self._EventBusClient:Publish(TopicConstants.UI.Close("InventoryUI"))
end

-- [ Public Functions ] --
function InventoryUIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIController = self._ServiceBag:GetService(require("UIController"))
    self._UserInputController = self._ServiceBag:GetService(require("UserInputController"))
    self._EventBusClient = self._ServiceBag:GetService(require("EventBusClient"))
    self._TabUIGridObjects = {}
    self._ItemUIObjects = {}
end

function InventoryUIController.Start(self: Module)
    self._UIController:Ready():Then(function(refs)
        local InventoryUIRefs: InventoryUIFactory.Refs = refs["InventoryUI"]
        local Actions = KeyMap.Actions
        local KeyMaps = KeyMap.KeyMaps

        local function setupGrids()
            for tabName, sectionsData in InventoryConstants.Tabs do
                local TabUI = InventoryUIRefs.Tabs:FindFirstChild(tabName)
    
                if not TabUI or not TabUI:IsA("ScrollingFrame") then
                    continue
                end
    
                local UIGridObject = UIGridClass.new(TabUI)
                
                for _, sectionName in sectionsData do
                    UIGridObject:CreateSection(sectionName)
                end

                self._TabUIGridObjects[tabName] = UIGridObject
            end
        end

        setupGrids()

        self:AddItem({
            ID = "1",
            Type = "Weapons",
            Name = "Hello",  
        })

        ButtonUtil:Hook(InventoryUIRefs.Close, function()
            self:Close()
        end)

        self._UserInputController:RegisterKeymapAction(
            Actions.TOGGLE_INVENTORY_UI,
            KeyMaps[Actions.TOGGLE_INVENTORY_UI],
            function(packet)
                if packet.InputState ~= Enum.UserInputState.Begin then
                    return
                end

                self._EventBusClient:Publish(TopicConstants.UI.Toggle("InventoryUI"))
            end
        )
    end)
end

return InventoryUIController :: Module
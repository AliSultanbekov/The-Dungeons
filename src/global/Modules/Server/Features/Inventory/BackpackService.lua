--[=[
    @class BackpackService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local Maid = require("Maid")
local AssetProvider = require("AssetProvider")
local ItemConstants = require("ItemConstants")
local TopicConstants = require("TopicConstants")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local BackpackService = {}

-- [ Types ] --
type UniqueItemData = ItemTypes.UniqueItemData
type StackableItemData = ItemTypes.StackableItemData
type ItemData = ItemTypes.ItemData
type ItemID = ItemTypes.ItemID
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PlayerService: typeof(require("PlayerService")),
    _InventoryService: typeof(require("InventoryService")),
    _EventBus: typeof(require("EventBus")),

    _PlayerBackpacks: { [Player]: { [ItemID]: Tool }}
}

export type Module = typeof(BackpackService) & ModuleData

-- [ Private Functions ] --
function BackpackService._UpdateTool(self: Module, tool: Tool, itemData: ItemData)
    local StorageType = ItemConstants.ItemTypeToStorageType[itemData.Type]

    local function handleUnique(unqiueItemData: UniqueItemData)
        tool.Name = unqiueItemData.Name
    end

    local function handleStackable(stackableItemData: StackableItemData)
        tool.Name = string.format("x%d %s", stackableItemData.Amount, stackableItemData.Name) 
    end

    if StorageType == "Unqiue" then
        handleUnique(itemData :: UniqueItemData)
    elseif StorageType == "Stackable" then
        handleStackable(itemData :: StackableItemData)
    end
end

function BackpackService._GetTool(self: Module, itemData: ItemData): Tool
    local ItemInstance = AssetProvider:Get(string.format("Objects/Items/%s/%s", itemData.Type, itemData.Name)) :: Tool

    if not ItemInstance then
        error(string.format("[BackpackService] Failed to get tool asset for item %s (type %s)", itemData.Name, itemData.Type))
    end

    self:_UpdateTool(ItemInstance, itemData)

    return ItemInstance
end

-- [ Public Functions ] --
function BackpackService.AddItem(self: Module, player: Player, itemData: ItemData)
    local PlayerBackpack = self._PlayerBackpacks[player]

    if PlayerBackpack[itemData.ID] then
        warn("[BackpackService] Player already has item with ID:", itemData.ID)
        return
    end

    local Tool = self:_GetTool(itemData)

    Tool.Parent = player.Backpack

    PlayerBackpack[itemData.ID] = Tool
end

function BackpackService.UpdateItem(self: Module, player: Player, itemData: ItemData)
    local PlayerBackpack = self._PlayerBackpacks[player]

    local Tool = PlayerBackpack[itemData.ID]

    if not Tool then
        return
    end

    self:_UpdateTool(Tool, itemData)
end

function BackpackService.RemoveItem(self: Module, player: Player, itemData: ItemData)
    local PlayerBackpack = self._PlayerBackpacks[player]

    local Tool = PlayerBackpack[itemData.ID]

    if not Tool then
        warn(string.format("[BackpackService] Tried to remove tool for item with ID %s, but it was not found in the player's backpack", itemData.ID))
        return
    end

    Tool:Destroy()

    PlayerBackpack[itemData.ID] = nil
end

function BackpackService.OnPlayerAdded(self: Module, maid: Maid.Maid, player: Player)
    self._PlayerBackpacks[player] = {}

    maid:Add(function()
        self._PlayerBackpacks[player] = nil
    end)
    
    for _, itemData in self._InventoryService:GetItemDatas(player) do
        if itemData.Equipped == true then
            self:AddItem(player, itemData)
        end
    end
end

function BackpackService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PlayerService = self._ServiceBag:GetService(require("PlayerService"))
    self._InventoryService = self._ServiceBag:GetService(require("InventoryService"))
    self._EventBus = self._ServiceBag:GetService(require("EventBus"))

    self._PlayerBackpacks = {}
end

function BackpackService.Start(self: Module)
    self._PlayerService:RegisterService(self)

    self._EventBus:Subscribe(TopicConstants.Inventory.ItemEquipped, function(packet: { Player: Player, ItemData: ItemData })
        self:AddItem(packet.Player, packet.ItemData)
    end)

    self._EventBus:Subscribe(TopicConstants.Inventory.ItemUnequipped, function(packet: { Player: Player, ItemData: ItemData })
        self:RemoveItem(packet.Player, packet.ItemData)
    end)
end

return BackpackService :: Module
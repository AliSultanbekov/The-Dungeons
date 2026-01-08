--[=[
    @class InventoryService
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local Table = require("Table")
local ItemConstants = require("ItemConstants")
local TopicConstants = require("TopicConstants")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryService = {}

-- [ Types ] --
type ItemID = ItemTypes.ItemID
type ItemData = ItemTypes.ItemData
type StackableItemData = ItemTypes.StackableItemData
type UniqueItemData = ItemTypes.UniqueItemData
type RawItemData = ItemTypes.RawItemData
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: typeof(require("DataService")),
    _NetworkService: typeof(require("NetworkService")),
    _EventBus: typeof(require("EventBus"))
}

export type Module = typeof(InventoryService) & ModuleData

-- [ Private Functions ] --
function InventoryService._GenerateID(self: Module, player: Player)
    local Success, PlayerInventoryData = self._DataService:GetData(player, "Inventory")

    if not Success then
        error("Failed to get Inventory data for player: " .. player.Name)
    end

    local ItemsData = {}

    for itemType, itemsData in PlayerInventoryData do
        ItemsData = Table.merge(ItemsData, itemsData)
    end

    local ID
    local Deadline = os.clock() + 2

    while (ID == nil or ItemsData[ID]) and Deadline > os.clock() do
        ID = HttpService:GenerateGUID(false)
    end

    return ID
end

function InventoryService._ProcessItemData(self: Module, player: Player, rawItemData: RawItemData): ItemData
    local StorageType = ItemConstants.ItemTypeToStorageType[rawItemData.Type]
    local ID = StorageType == "Unique" and self:_GenerateID(player) or rawItemData.Name
    
    if rawItemData.Type == "Weapons" then
        local ItemData = {
            ID = ID,
            Type = rawItemData.Type,
            Name = rawItemData.Name,
            Equipped = false,
        }
        return ItemData
    elseif rawItemData.Type == "Materials" then
        local ItemData = {
            ID = ID,
            Type = rawItemData.Type,
            Name = rawItemData.Name,
            Amount = rawItemData.Amount,
            Equipped = false,
        }
        return ItemData
    else
        error(`No processing implemented for item type {rawItemData.Type}`)
    end
end

--[=[
    since we only want to transmit the change in amount to client, we also need to make sure that the new stackable data has correct attributes,
    like equipped etc. if you did transmit the wrong states from itemdata, it would end up with bugs
]=]
function InventoryService._CreateDelta(self: Module, itemData: StackableItemData, deltaAmount: number)
    local Copy = Table.deepCopy(itemData) :: StackableItemData
    Copy.Amount = deltaAmount

    return Copy
end

-- [ Public Functions ] --

--[=[
    itemData here is secure and up to date
]=]
function InventoryService.Equip(self: Module, player: Player, itemData: ItemData)
    local Network = self._NetworkService:GetNetwork("InventoryService")

    local function handleUnique(InventoryData: {})
        (itemData :: UniqueItemData).Equipped = true
    end

    local function handleStackable(InventoryData: {})
        (itemData :: StackableItemData).Equipped = true
    end

    if itemData.Equipped == true then
        return
    end

    self._DataService:UpdateData(player, function(data)
        local InventoryData = data.Inventory

        if itemData.Type == "Materials" then
            handleStackable(InventoryData)
        elseif itemData.Type == "Weapons" then
            handleUnique(InventoryData)
        end
    end)

    self._EventBus:Publish(TopicConstants.Inventory.ItemEquipped, { Player = player, ItemData = itemData })

    Network:FireClient("ItemEquipped", player, itemData)
end

--[=[
    itemData here is secure and up to date
]=]
function InventoryService.Unequip(self: Module, player: Player, itemData: ItemData)
    local Network = self._NetworkService:GetNetwork("InventoryService")

    local function handleUnique(InventoryData: {})
        (itemData :: UniqueItemData).Equipped = false
    end

    local function handleStackable(InventoryData: {})
        (itemData :: StackableItemData).Equipped = false
    end

    if itemData.Equipped == false then
        return
    end

    self._DataService:UpdateData(player, function(data)
        local InventoryData = data.Inventory

        if itemData.Type == "Materials" then
            handleStackable(InventoryData)
        elseif itemData.Type == "Weapons" then
            handleUnique(InventoryData)
        end
    end)

    self._EventBus:Publish(TopicConstants.Inventory.ItemUnequipped, { Player = player, ItemData = itemData })

    Network:FireClient("ItemUnequipped", player, itemData)
end

--[=[
    only ever gets called from server       
]=]
function InventoryService.AddItems(self: Module, player: Player, rawItemDataMap: { [any]: RawItemData })
    local Network = self._NetworkService:GetNetwork("InventoryService")

    self._DataService:UpdateData(player, function(data)
        local function handleUnique(inventoryData: {}, deltaCache: {}, itemData: UniqueItemData)
            inventoryData[itemData.Type][itemData.ID] = itemData
            deltaCache[itemData.ID] = itemData
            self._EventBus:Publish(TopicConstants.Inventory.ItemAdded, { Player = player, ItemData = itemData })
        end
    
        local function handleStackable(inventoryData: {}, deltaCache: {}, itemData: StackableItemData)
            local ExistingItemData: StackableItemData? = inventoryData[itemData.Type][itemData.ID]
            local DeltaAmount = itemData.Amount -- the change aka how much being added
    
            local function updateDatastore()
                if ExistingItemData then
                    ExistingItemData.Amount += DeltaAmount
                    itemData = self:_CreateDelta(ExistingItemData, DeltaAmount)
                else
                    inventoryData[itemData.Type][itemData.ID] = itemData
                end
            end
    
            local function updateCache()
                local DeltaItemData = deltaCache[itemData.ID]
    
                if DeltaItemData then
                    DeltaItemData.Amount += DeltaAmount
                else
                    deltaCache[itemData.ID] = itemData
                end
            end
    
            updateDatastore()
            updateCache()
        end
        
        local InventoryData = data.Inventory
        local DeltaCache: { [ItemID]: ItemData } = {}

        for _, rawItemData in rawItemDataMap do
            local ItemData = self:_ProcessItemData(player, rawItemData)

            if not InventoryData[ItemData.Type] then
                warn(`[InventoryService.AddItem] InventoryData[{ItemData.Type}] does not exist for player {player.Name}`)
                continue
            end

            if ItemData.Type == "Materials" then
                handleStackable(InventoryData, DeltaCache, ItemData)
            elseif ItemData.Type == "Weapons" then
                handleUnique(InventoryData, DeltaCache, ItemData)
            end
        end

        if next(DeltaCache) == nil then
            warn("[BackpackService] No items were added to the cache for player: " .. tostring(player))
            return
        end

        Network:FireClient("ItemsAdded", player, DeltaCache)
    end)
end

--[=[
    itemdata might come from client, make sure to validate

    only use item ids and item types
]=]
function InventoryService.RemoveItems(self: Module, player: Player, ItemDataMap: { [any]: ItemData })
    local Network = self._NetworkService:GetNetwork("InventoryService")

    self._DataService:UpdateData(player, function(data)
        local InventoryData = data.Inventory
        local DeltaCache: { [ItemID]: ItemData } = {}

        local function handleUnique(inventoryData: {}, deltaCache: {}, itemData: UniqueItemData)
            inventoryData[itemData.Type][itemData.ID] = nil
            deltaCache[itemData.ID] = itemData
            self._EventBus:Publish(TopicConstants.Inventory.ItemDeleted, { Player = player, ItemData = itemData })
        end
    
        local function handleStackable(inventoryData: {}, deltaCache: {}, itemData: StackableItemData)
            local ExistingItemData: StackableItemData? = inventoryData[itemData.Type][itemData.ID]
            local DeltaAmount = itemData.Amount
    
            if not ExistingItemData then
                warn(`[InventoryService.RemoveItem] Tried to remove item {itemData.ID} of type {itemData.Type} which does not exist in inventory for player {player.Name}`)
                return
            end
    
            local function updateDatastore()
                if ExistingItemData.Amount - DeltaAmount <= 0 then
                    DeltaAmount = DeltaAmount + (ExistingItemData.Amount - DeltaAmount)
                    inventoryData[itemData.Type][itemData.ID] = nil
                else
                    ExistingItemData.Amount -= DeltaAmount
                end
    
                itemData = self:_CreateDelta(ExistingItemData, DeltaAmount)
            end
    
            local function updateCache()
                local ExistingCacheItemData: StackableItemData? = deltaCache[itemData.ID]
    
                if ExistingCacheItemData then
                    ExistingCacheItemData.Amount += DeltaAmount
                else
                    deltaCache[itemData.ID] = itemData
                end
            end
    
            updateDatastore()
            updateCache()
        end
        
        for _, itemData in ItemDataMap do
            if not InventoryData[itemData.Type] then
                warn(`[InventoryService.AddItem] InventoryData[{itemData.Type}] does not exist for player {player.Name}`)
                continue
            end

            if not InventoryData[itemData.Type][itemData.ID] then
                warn(`[InventoryService.RemoveItem] InventoryData[{itemData.Type}][{itemData.ID}] does not exist for player {player.Name}`)
                continue
            end

            if itemData.Type == "Materials" then
                handleStackable(InventoryData, DeltaCache, itemData)
            elseif itemData.Type == "Weapons" then
                handleUnique(InventoryData, DeltaCache, itemData)
            end
        end

        if next(DeltaCache) == nil then
            warn("[BackpackService] No items were added to the cache for player: " .. tostring(player))
            return
        end

        Network:FireClient("ItemsRemoved", player, DeltaCache)
    end)
end

function InventoryService.FetchSecureItemData(self: Module, player: Player, itemData: ItemData): ItemData?
    local _, SecureData = self._DataService:GetData(player, string.format("Inventory/%s/%s", itemData.Type, itemData.ID))

    return SecureData
end

function InventoryService.GetItemDatas(self: Module, player: Player): { [ItemID]: ItemData}
    local Success, InventoryData = self._DataService:GetData(player, "Inventory")

    if not Success then
        error("Failed to get Inventory data for player: " .. player.Name)
    end

    local ItemsData = {}


    for _, itemsData in InventoryData do
        ItemsData = Table.merge(ItemsData, itemsData)
    end

    return ItemsData
end

function InventoryService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataService = self._ServiceBag:GetService(require("DataService"))
    self._NetworkService = self._ServiceBag:GetService(require("NetworkService"))
    self._EventBus = self._ServiceBag:GetService(require("EventBus"))
end

function InventoryService.Start(self: Module)
    local Network = self._NetworkService:GetNetwork("InventoryService")

    -- Client --
    Network:DeclareEvent("RemoveItems")
    Network:DeclareMethod("GetItemDatas")
    Network:DeclareEvent("EquipItem")
    Network:DeclareEvent("UnequipItem")

    -- Server --
    Network:DeclareEvent("ItemsAdded")
    Network:DeclareEvent("ItemsRemoved")
    Network:DeclareEvent("ItemEquipped")
    Network:DeclareEvent("ItemUnequipped")
    
    -- Implementation --
    Network:Connect("RemoveItems", function(player: Player, itemDataMap: { [any]: ItemData })
        self:RemoveItems(player, itemDataMap)
    end)

    Network:Bind("GetItemDatas", function(player: Player)
        return self:GetItemDatas(player)
    end)

    Network:Connect("EquipItem", function(player: Player, itemData: ItemData)  
        local SecureItemData = self:FetchSecureItemData(player, itemData)

        if not SecureItemData then
            return
        end

        self:Equip(player, SecureItemData)
    end)

    Network:Connect("UnequipItem", function(player: Player, itemData: ItemData)  
        local SecureItemData = self:FetchSecureItemData(player, itemData)

        if not SecureItemData then
            return
        end

        self:Unequip(player, SecureItemData)
    end)
    --

    task.spawn(function()
        task.wait(3)
        local player = Players:GetPlayers()[1]
        if not player then
            return
        end

        self:AddItems(player, {
            {
                Type = "Materials",
                Name = "Wooden Plank",
                Amount = 10,
            },
            {
                Type = "Weapons",
                Name = "Wooden Sword",
            },
            {
                Type = "Weapons",
                Name = "Wooden Sword",
            },
            {
                Type = "Weapons",
                Name = "Wooden Sword",
            },
            {
                Type = "Weapons",
                Name = "Wooden Sword",
            },
            {
                Type = "Weapons",
                Name = "Wooden Sword",
            },
            {
                Type = "Weapons",
                Name = "Wooden Sword",
            },
            {
                Type = "Weapons",
                Name = "Wooden Sword",
            },
        })
    end)
end



return InventoryService :: Module
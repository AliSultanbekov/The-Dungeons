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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryService = {}

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type StackableItemData = ItemTypes.StackableItemData
type UniqueItemData = ItemTypes.UniqueItemData
type RawItemData = ItemTypes.RawItemData
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: typeof(require("DataService")),
    _NetworkService: typeof(require("NetworkService"))
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
        }
        return ItemData
    elseif rawItemData.Type == "Materials" then
        local ItemData = {
            ID = ID,
            Type = rawItemData.Type,
            Name = rawItemData.Name,
            Amount = rawItemData.Amount,
        }
        return ItemData
    else
        error(`No processing implemented for item type {rawItemData.Type}`)
    end
end

-- [ Public Functions ] --

--[=[
    only ever gets called from server
]=]
function InventoryService.AddItems(self: Module, player: Player, rawItemDataMap: { [any]: RawItemData })
    local Network = self._NetworkService:GetNetwork("InventoryService")

    self._DataService:UpdateData(player, function(data)
        local InventoryData = data.Inventory
        local CacheMap: { [string]: ItemData } = {}

        for _, rawItemData in rawItemDataMap do
            local ItemData = self:_ProcessItemData(player, rawItemData)

            if not InventoryData[ItemData.Type] then
                warn(`[InventoryService.AddItem] InventoryData[{ItemData.Type}] does not exist for player {player.Name}`)
                continue
            end

            if ItemData.Type == "Materials" then
                local ExistingItemData: StackableItemData = InventoryData[ItemData.Type][ItemData.ID]

                if ExistingItemData then
                    ExistingItemData.Amount += ItemData.Amount
                else
                    InventoryData[ItemData.Type][ItemData.ID] = ItemData
                end

                local ExistingItemDataInBag = CacheMap[ItemData.ID]

                if ExistingItemDataInBag then
                    if ExistingItemDataInBag.Type ~= ItemData.Type then
                        continue
                    end

                    if ExistingItemDataInBag then
                        ExistingItemDataInBag.Amount += ItemData.Amount
                    end
                else
                    CacheMap[ItemData.ID] = ItemData
                end
            elseif ItemData.Type == "Weapons" then
                InventoryData[ItemData.Type][ItemData.ID] = ItemData
                CacheMap[ItemData.ID] = ItemData
            end
        end

        Network:FireClient("ItemsAdded", player, CacheMap)
    end)
end

--[=[
    itemdata might come from client, make sure to validate

    make sure to only use ids
]=]
function InventoryService.RemoveItems(self: Module, player: Player, ItemDataMap: { [any]: ItemData })
    local Network = self._NetworkService:GetNetwork("InventoryService")

    self._DataService:UpdateData(player, function(data)
        local InventoryData = data.Inventory
        local CacheMap: { [string]: ItemData } = {}

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
                local ExistingItemData: StackableItemData = InventoryData[itemData.Type][itemData.ID]

                if ExistingItemData.Amount - itemData.Amount < 0 then
                    InventoryData[itemData.Type][itemData.ID] = nil
                else
                    ExistingItemData.Amount -= itemData.Amount
                end
                
                local ExistingItemDataInBag = CacheMap[itemData.ID]

                if ExistingItemDataInBag then
                    if ExistingItemDataInBag.Type ~= itemData.Type then
                        continue
                    end

                    if ExistingItemDataInBag then
                        ExistingItemDataInBag.Amount += itemData.Amount
                    end
                else
                    CacheMap[itemData.ID] = itemData
                end
            elseif itemData.Type == "Weapons" then
                InventoryData[itemData.Type][itemData.ID] = nil
                CacheMap[itemData.ID] = itemData
            end
        end

        Network:FireClient("ItemsRemoved", player, CacheMap)
    end)
end

function InventoryService.GetItemDatas(self: Module, player)
    local Success, InventoryData = self._DataService:GetData(player, "Inventory")

    if not Success then
        return
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
end

function InventoryService.Start(self: Module)
    local Network = self._NetworkService:GetNetwork("InventoryService")

    -- Client --
    Network:DeclareEvent("ItemsAdded")
    Network:DeclareEvent("ItemsRemoved")
    -- Server --
    Network:DeclareEvent("RemoveItems")
    Network:DeclareMethod("GetItemDatas")
    
    Network:Connect("RemoveItems", function(player: Player, itemDataMap: { [any]: ItemData })
        print("aaAAaa")
        self:RemoveItems(player, itemDataMap)
    end)

    Network:Bind("GetItemDatas", function(player: Player)
        return self:GetItemDatas(player)
    end)

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
        })
    end)
end



return InventoryService :: Module
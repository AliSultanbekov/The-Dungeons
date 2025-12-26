--[=[
    @class InventoryService
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local ItemConstants = require("ItemConstants")
local Table = require("Table")


-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryService = {}

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type RawItemData = ItemTypes.RawItemData
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: typeof(require("DataService")),
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
        if ItemConstants.ItemTypeToStorageType[itemType] == "Stackable" then
            continue
        end

        Table.merge(ItemsData, itemsData)
    end

    local ID
    local Deadline = os.clock() + 2

    while (ID == nil or ItemsData[ID]) and Deadline > os.clock() do
        ID = HttpService:GenerateGUID()
    end

    return ID
end

function InventoryService._ProcessItemData(self: Module, player: Player, rawItemData: RawItemData): ItemData
    local StorageType = ItemConstants.ItemTypeToStorageType[rawItemData.Type]
    local ID = StorageType == "Unqiue" and self:_GenerateID(player) or rawItemData.Name
    
    if rawItemData.Type == "Weapons" then
        local ItemData: ItemData = {
            ID = ID,
            Type = rawItemData.Type,
            Name = rawItemData.Name or error("No name was found"),
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
function InventoryService.AddItem(self: Module, player: Player, rawItemDataArray: { RawItemData })
    self._DataService:UpdateData(player, function(data)
        for _, rawItemData in rawItemDataArray do
            local ItemData = self:_ProcessItemData(player, rawItemData)
            local StorageType = ItemConstants.ItemTypeToStorageType[ItemData.Type]

            if StorageType == "Unqiue" then
                data.Inventory[ItemData.Type][ItemData.ID] = ItemData
            else
                -- later
            end
        end
    end)
end

--[=[
    itemdata might come from client, make sure to validate
]=]
function InventoryService.RemoveItem(self: Module, player: Player, rawItemDataArray: { RawItemData })

end

function InventoryService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataService = self._ServiceBag:GetService(require("DataService"))
end

function InventoryService.Start(self: Module)

end



return InventoryService :: Module
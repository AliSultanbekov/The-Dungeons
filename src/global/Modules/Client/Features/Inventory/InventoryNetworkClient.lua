--[=[
    @class InventoryNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local InventoryTypes = require("InventoryTypes")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryNetworkClient = {}

-- [ Types ] --
type ItemData = ItemTypes.ItemData

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
    RemoteEvents: {
        ItemsAdded: Signal.Signal<(InventoryTypes.ItemsAddedRemotePacket)>,
        ItemsRemoved: Signal.Signal<(InventoryTypes.ItemsRemovedRemotePacket)>,
        ItemUpdated: Signal.Signal<(InventoryTypes.ItemUpdatedRemotePacket)>,
    }
}

export type Module = typeof(InventoryNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InventoryNetworkClient.EquipItem(self: Module, itemData: InventoryTypes.EquipItemRemotePacket)
    local InventoryChannel = self._NetworkManager:GetNetwork("Inventory")

    InventoryChannel:FireServer("EquipItem", itemData)
end

function InventoryNetworkClient.UnequipItem(self: Module, itemData: InventoryTypes.UnequipItemRemotePacket)
    local InventoryChannel = self._NetworkManager:GetNetwork("Inventory")

    InventoryChannel:FireServer("UnequipItem", itemData)
end

function InventoryNetworkClient.RemoveItems(self: Module, itemsData: InventoryTypes.RemoveItemsRemotePacket)
    local InventoryChannel = self._NetworkManager:GetNetwork("Inventory")
    
    InventoryChannel:FireServer("RemoveItems", itemsData)
end

function InventoryNetworkClient.GetItemsData(self: Module): InventoryTypes.GetItemsDataRemotePacket
    local InventoryChannel = self._NetworkManager:GetNetwork("Inventory")

    return InventoryChannel:PromiseInvokeServer("GetItemsData"):Wait()
end

function InventoryNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(require("NetworkManager"))

    self.RemoteEvents = {
        ItemsAdded = Signal.new() :: any,
        ItemsRemoved = Signal.new() :: any,
        ItemUpdated = Signal.new() :: any,
    }
end

function InventoryNetworkClient.Start(self: Module)
    local InventoryChannel = self._NetworkManager:GetNetwork("Inventory")

    InventoryChannel:Connect("ItemsAdded", function(itemsData: InventoryTypes.ItemsAddedRemotePacket)
        self.RemoteEvents.ItemsAdded:Fire(itemsData)
    end)

    InventoryChannel:Connect("ItemsRemoved", function(itemsData: InventoryTypes.ItemsRemovedRemotePacket)
        self.RemoteEvents.ItemsRemoved:Fire(itemsData)
    end)

    InventoryChannel:Connect("ItemUpdated", function(itemData: InventoryTypes.ItemUpdatedRemotePacket)
        self.RemoteEvents.ItemUpdated:Fire(itemData)
    end)
end

return InventoryNetworkClient :: Module
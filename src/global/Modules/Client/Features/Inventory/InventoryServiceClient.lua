--[=[
    @class InventoryServiceClient
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
local InventoryServiceClient = {}

-- [ Types ] --
type ItemEquippedRemotePacket = InventoryTypes.ItemEquippedRemotePacket
type ItemUnequippedRemotePacket = InventoryTypes.ItemUnequippedRemotePacket
type GetItemDatasRemotePacket = InventoryTypes.GetItemDatasRemotePacket
type ItemsRemovedRemotePacket = InventoryTypes.ItemsRemovedRemotePacket
type ItemsAddedRemotePacket = InventoryTypes.ItemsAddedRemotePacket
type ItemData = ItemTypes.ItemData

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceClient: typeof(require("NetworkServiceClient")),
    PublicSignals: {
        ItemsAdded: Signal.Signal<(ItemsAddedRemotePacket)>,
        ItemsRemoved: Signal.Signal<(ItemsRemovedRemotePacket)>,
        ItemUnequipped: Signal.Signal<(ItemUnequippedRemotePacket)>,
        ItemEquipped: Signal.Signal<(ItemEquippedRemotePacket)>,
    }
}

export type Module = typeof(InventoryServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InventoryServiceClient.EquipItem(self: Module, itemData: ItemData)
    local Network = self._NetworkServiceClient:GetNetwork("InventoryService")

    Network:FireServer("EquipItem", itemData)
end

function InventoryServiceClient.UnequipItem(self: Module, itemData: ItemData)
    local Network = self._NetworkServiceClient:GetNetwork("InventoryService")

    Network:FireServer("UnequipItem", itemData)
end

function InventoryServiceClient.RemoveItems(self: Module, itemDataMap: { [any]: ItemData })
    local Network = self._NetworkServiceClient:GetNetwork("InventoryService")
    Network:FireServer("RemoveItems", itemDataMap)
end

function InventoryServiceClient.GetItemDatas(self: Module): GetItemDatasRemotePacket
    local Network = self._NetworkServiceClient:GetNetwork("InventoryService")

    return Network:PromiseInvokeServer("GetItemDatas"):Wait()
end

function InventoryServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceClient = self._ServiceBag:GetService(require("NetworkServiceClient"))

    self.PublicSignals = {
        ItemsAdded = Signal.new() :: any,
        ItemsRemoved = Signal.new() :: any,
        ItemUnequipped = Signal.new() :: any,
        ItemEquipped = Signal.new() :: any,
    }
end

function InventoryServiceClient.Start(self: Module)
    local Network = self._NetworkServiceClient:GetNetwork("InventoryService")

    Network:Connect("ItemsAdded", function(itemDataMap: ItemsAddedRemotePacket)
        self.PublicSignals.ItemsAdded:Fire(itemDataMap)
    end)

    Network:Connect("ItemsRemoved", function(itemDataMap: ItemsRemovedRemotePacket)
        self.PublicSignals.ItemsRemoved:Fire(itemDataMap)
    end)

    Network:Connect("ItemUnequipped", function(itemData: ItemUnequippedRemotePacket)
        self.PublicSignals.ItemUnequipped:Fire(itemData)
    end)

    Network:Connect("ItemEquipped", function(itemData: ItemEquippedRemotePacket)
        self.PublicSignals.ItemEquipped:Fire(itemData)
    end)
end

return InventoryServiceClient :: Module
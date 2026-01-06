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
type GetItemDatasRemotePacket = InventoryTypes.GetItemDatasRemotePacket
type ItemsRemovedRemotePacket = InventoryTypes.ItemsRemovedRemotePacket
type ItemsAddedRemotePacket = InventoryTypes.ItemsAddedRemotePacket
type ItemData = ItemTypes.ItemData

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceClient: typeof(require("NetworkServiceClient")),
    PublicSignals: {
        ItemsAdded: Signal.Signal<(ItemsAddedRemotePacket)>,
        ItemsRemoved: Signal.Signal<(ItemsRemovedRemotePacket)>
    }
}

export type Module = typeof(InventoryServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
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
    }
end

function InventoryServiceClient.Start(self: Module)
    local Network = self._NetworkServiceClient:GetNetwork("InventoryService")

    Network:Connect("ItemsAdded", function(packet: ItemsAddedRemotePacket)
        self.PublicSignals.ItemsAdded:Fire(packet)
    end)

    Network:Connect("ItemsRemoved", function(packet: ItemsRemovedRemotePacket)
        self.PublicSignals.ItemsRemoved:Fire(packet)
    end)
end

return InventoryServiceClient :: Module
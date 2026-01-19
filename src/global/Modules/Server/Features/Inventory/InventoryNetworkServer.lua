--[=[
    @class InvetoryService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local ItemTypes = require("ItemTypes")
local InventoryTypes = require("InventoryTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InvetoryServiceServer = {}

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
    RemoteEvents: {
        ["RemoveItems"]: Signal.Signal<(Player, { [any]: ItemData })>,
        ["EquipItem"]: Signal.Signal<(Player, ItemData)>,
        ["UnequipItem"]: Signal.Signal<(Player, ItemData)>,
    },
    RemoteFunctions: { GetItemsData: (player: Player) ->  { [any]: ItemData } }
}

export type Module = typeof(InvetoryServiceServer) & ModuleData

-- [ Private Functions ] --
function InvetoryServiceServer.ItemsAdded(self: Module, player: Player, itemsData: InventoryTypes.ItemsAddedRemotePacket)
    local InventoryServiceChannel = self._NetworkManager:GetNetwork("Inventory")
    InventoryServiceChannel:FireClient("ItemsAdded", player, itemsData)
end

function InvetoryServiceServer.ItemsRemoved(self: Module, player: Player, itemsData: InventoryTypes.ItemsRemovedRemotePacket)
    local InventoryServiceChannel = self._NetworkManager:GetNetwork("Inventory")
    InventoryServiceChannel:FireClient("ItemsRemoved", player, itemsData)
end

function InvetoryServiceServer.ItemUpdated(self: Module, player: Player, itemData: InventoryTypes.ItemUpdatedRemotePacket)
    local InventoryServiceChannel = self._NetworkManager:GetNetwork("Inventory")
    InventoryServiceChannel:FireClient("ItemUpdated", player, itemData)
end

-- [ Public Functions ] --
function InvetoryServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(require("NetworkManager"))

    self.RemoteEvents = {
        RemoveItems = Signal.new() :: any,
        EquipItem = Signal.new() :: any,
        UnequipItem = Signal.new() :: any
    }   
    self.RemoteFunctions = {
        
    } :: any
end

function InvetoryServiceServer.Start(self: Module)
    local InventoryChannel = self._NetworkManager:GetNetwork("Inventory")

    -- Client --
    InventoryChannel:DeclareMethod("GetItemsData")

    InventoryChannel:DeclareEvent("RemoveItems")
    InventoryChannel:DeclareEvent("EquipItem")
    InventoryChannel:DeclareEvent("UnequipItem")

    -- Server --
    InventoryChannel:DeclareEvent("ItemsAdded")
    InventoryChannel:DeclareEvent("ItemsRemoved")
    InventoryChannel:DeclareEvent("ItemUpdated")
    
    InventoryChannel:Connect("RemoveItems", function(player: Player, itemDataMap: { [any]: ItemData })
        self.RemoteEvents.RemoveItems:Fire(player, itemDataMap)
    end)

    InventoryChannel:Connect("EquipItem", function(player: Player, itemData: ItemData)  
        self.RemoteEvents.EquipItem:Fire(player, itemData)
    end)

    InventoryChannel:Connect("UnequipItem", function(player: Player, itemData: ItemData)  
        self.RemoteEvents.UnequipItem:Fire(player, itemData)
    end)

    InventoryChannel:Bind("GetItemsData", function(player: Player)
        return self.RemoteFunctions.GetItemsData(player)
    end)
end

return InvetoryServiceServer :: Module
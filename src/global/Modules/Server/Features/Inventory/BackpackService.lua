local Players = game:GetService("Players")
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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local BackpackService = {}

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(BackpackService) & ModuleData

-- [ Private Functions ] --
function BackpackService.AddItem(self: Module, player: Player, itemData: ItemData)

end

function BackpackService.RemoveItem(self: Module, player: Player, ItemData: ItemData)
    
end

-- [ Public Functions ] --
function BackpackService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function BackpackService.Start(self: Module)

end

return BackpackService :: Module
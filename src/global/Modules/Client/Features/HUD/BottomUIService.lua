--[=[
    @class BottomUIService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local CreatureTypesClient = require("CreatureTypesClient")
local Jecs = require("Jecs")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local BottomUIService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIManager: typeof(require("UIManager")),
    _CreatureServiceClient: typeof(require("CreatureServiceClient")),
    _CharacterMaid: Maid.Maid,
}

export type Module = typeof(BottomUIService) & ModuleData

-- [ Private Functions ] --
function BottomUIService._Setup(self: Module, character: Model)
    self._CharacterMaid:DoCleaning()

    self._CharacterMaid:Add(self._CreatureServiceClient:ObserveCreatureHealth(character, function(newHealth: number)
        self:_UpdateHealth(newHealth)
    end))
end

function BottomUIService._UpdateHealth(self: Module, newHealth: number)
    local Health = self._UIManager:GetUIComponent("BottomUI", "UIComponent_Health")

end

-- [ Public Functions ] --
function BottomUIService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIManager = self._ServiceBag:GetService(require("UIManager"))
    self._CreatureServiceClient = self._ServiceBag:GetService(require("CreatureServiceClient"))
    self._CharacterMaid = Maid.new()
end

function BottomUIService.Start(self: Module)
    self._UIManager:UIReady():Then(function()
        self._CreatureServiceClient:ObservePlayerCreature(Player, function(character: Model)
            self:_Setup(character)
        end)
    end)
end

return BottomUIService :: Module
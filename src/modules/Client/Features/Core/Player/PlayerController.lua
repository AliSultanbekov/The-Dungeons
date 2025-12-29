local Players = game:GetService("Players")
--[=[
    @class PlayerController
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local RxPlayerUtils = require("RxPlayerUtils")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlayerController = {}

-- [ Types ] --
type ControllerTemplate = {
    OnPlayerAdded: ((self: any, maid: Maid.Maid, player: Player) -> ())?,
    OnCharacterAdded: ((self: any, maid: Maid.Maid, character: Model) -> ())?
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _Controllers: { ControllerTemplate },
    _Players: { [string]: Player },
    _Characters: { [Player]: Model }
}

export type Module = typeof(PlayerController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PlayerController.RegisterController(self: Module, controller: ControllerTemplate)
    table.insert(self._Controllers, controller)
end

function PlayerController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._Controllers = {}
    self._Players = {}
    self._Characters = {}
end

function PlayerController.Start(self: Module)
    self._Maid:GiveTask(RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
        local Maid: Maid.Maid, Player: Player = brio:ToMaidAndValue()

        for _, controller in ipairs(self._Controllers) do
			if controller.OnPlayerAdded then
				task.spawn(controller.OnPlayerAdded, controller, Maid, Player)
			end
		end
    end))

    self._Maid:GiveTask(RxPlayerUtils.observeCharactersBrio():Subscribe(function(brio)
        local Maid: Maid.Maid, Character: Model = brio:ToMaidAndValue()
        local PlayerFromChar = Players:GetPlayerFromCharacter(Character)

        if not PlayerFromChar then
            return
        end

        self._Characters[PlayerFromChar] = Character

        Maid:GiveTask(function()
            self._Characters[PlayerFromChar] = nil
        end)

        for _, controller in ipairs(self._Controllers) do
			if controller.OnCharacterAdded then
				task.spawn(controller.OnCharacterAdded, controller, Maid, Character)
			end
		end
    end))
end

return PlayerController :: Module
--[=[
    @class PlayerService
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
local PlayerService = {}

-- [ Types ] --
type ServiceTemplate = {
    OnPlayerAdded: ((self: any, maid: Maid.Maid, player: Player) -> ())?,
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _Services: { ServiceTemplate },
}

export type Module = typeof(PlayerService) & ModuleData

-- [ Private Functions ] --
function PlayerService.RegisterService(self: Module, service: ServiceTemplate)
    table.insert(self._Services, service)
end

-- [ Public Functions ] --
function PlayerService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._Services = {}
end

function PlayerService.Start(self: Module)
    self._Maid:GiveTask(RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
        local Maid: Maid.Maid, Player: Player = brio:ToMaidAndValue()

        for _, service in ipairs(self._Services) do
			if service.OnPlayerAdded then
				task.spawn(service.OnPlayerAdded, service, Maid, Player)
			end
		end
    end))
end

return PlayerService :: Module
--[=[
    @class PlayerCharacterController
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
local PlayerCharacterController = {}

-- [ Types ] --
type ServiceModule = {
    OnPlayerCharacterAdded: (self: ServiceModule, maid: Maid.Maid, character: Model) -> ()?
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _Services: { ServiceModule }
}

export type Module = typeof(PlayerCharacterController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PlayerCharacterController.RegisterService(self: Module, service: ServiceModule)
    table.insert(self._Services, service)
end

function PlayerCharacterController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._Services = {}
end

function PlayerCharacterController.Start(self: Module)
    self._Maid:Add(RxPlayerUtils.observeCharactersBrio():Subscribe(function(brio)
        local Maid: Maid.Maid, Character: Model = brio:ToMaidAndValue()

        for _, service in ipairs(self._Services) do
			if service.OnPlayerCharacterAdded then
				task.spawn(service.OnPlayerCharacterAdded, service, Maid, Character)
			end
		end
    end))
end

return PlayerCharacterController :: Module
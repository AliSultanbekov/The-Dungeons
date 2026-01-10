--[=[
    @class CharacterService
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
local CharacterService = {}

-- [ Types ] --
type ServiceTemplate = {
    OnCharacterAdded: (self: ServiceTemplate, maid: Maid.Maid, character: Model) -> ()?
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _Services: { ServiceTemplate }
}

export type Module = typeof(CharacterService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CharacterService.RegisterService(self: Module, service: ServiceTemplate)
    table.insert(self._Services, service)
end

function CharacterService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._Services = {}
end

function CharacterService.Start(self: Module)
    self._Maid:Add(RxPlayerUtils.observeCharactersBrio():Subscribe(function(brio)
        local Maid: Maid.Maid, Character: Model = brio:ToMaidAndValue()

        for _, service in ipairs(self._Services) do
			if service.OnCharacterAdded then
				task.spawn(service.OnCharacterAdded, service, Maid, Character)
			end
		end
    end))
end

return CharacterService :: Module
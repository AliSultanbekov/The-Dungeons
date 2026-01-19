--[=[
    @class PlayerCharacterManager
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
local PlayerCharacterManager = {}

-- [ Types ] --
type ModuleTemplate = {
    OnPlayerCharacterAdded: (self: ModuleTemplate, maid: Maid.Maid, character: Model) -> ()?
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _Modules: { ModuleTemplate }
}

export type Module = typeof(PlayerCharacterManager) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PlayerCharacterManager.RegisterModule(self: Module, module: ModuleTemplate)
    table.insert(self._Modules, module)
end

function PlayerCharacterManager.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._Modules = {}
end

function PlayerCharacterManager.Start(self: Module)
    self._Maid:Add(RxPlayerUtils.observeCharactersBrio():Subscribe(function(brio)
        local Maid: Maid.Maid, Character: Model = brio:ToMaidAndValue()

        for _, module in ipairs(self._Modules) do
			if module.OnPlayerCharacterAdded then
				task.spawn(module.OnPlayerCharacterAdded, module, Maid, Character)
			end
		end
    end))
end

return PlayerCharacterManager :: Module
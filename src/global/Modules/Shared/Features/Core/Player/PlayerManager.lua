--[=[
    @class PlayerManager
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
local PlayerManager = {}

-- [ Types ] --
type ModuleTemplate = {
    OnPlayerAdded: ((self: any, maid: Maid.Maid, player: Player) -> ())?,
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _Modules: { ModuleTemplate },
}

export type Module = typeof(PlayerManager) & ModuleData

-- [ Private Functions ] --
function PlayerManager.RegisterModule(self: Module, module: ModuleTemplate)
    table.insert(self._Modules, module)
end

-- [ Public Functions ] --
function PlayerManager.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._Modules = {}
end

function PlayerManager.Start(self: Module)
    self._Maid:Add(RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
        local Maid: Maid.Maid, Player: Player = brio:ToMaidAndValue()

        for _, module in ipairs(self._Modules) do
			if module.OnPlayerAdded then
				task.spawn(module.OnPlayerAdded, module, Maid, Player)
			end
		end
    end))
end

return PlayerManager :: Module
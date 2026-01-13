--[=[
    @class CombatService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local StatTypes = require("StatsTypes")
local EnemyConfigs = require("EnemyConfigs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkService: typeof(require("NetworkService")),
}

export type Module = typeof(CombatService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkService = self._ServiceBag:GetService(require("NetworkService"))
end

function CombatService.Start(self: Module)
    print(EnemyConfigs)
end

return CombatService :: Module
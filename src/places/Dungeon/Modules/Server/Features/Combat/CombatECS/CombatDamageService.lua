--[=[
    @class CombatDamageService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
--local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatDamageService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatEntityService: typeof(require("CombatEntityService"))
}

export type Module = typeof(CombatDamageService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

function CombatDamageService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatEntityService = self._ServiceBag:GetService(require("CombatEntityService"))
end

function CombatDamageService.Start(self: Module)

end

return CombatDamageService :: Module
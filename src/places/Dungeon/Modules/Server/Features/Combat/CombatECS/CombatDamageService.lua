--[=[
    @class CombatDamageService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatDamageService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatEntityServiceServer: typeof(require("CombatEntityServiceServer"))
}

export type Module = typeof(CombatDamageService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

function CombatDamageService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatEntityServiceServer = self._ServiceBag:GetService(require("CombatEntityServiceServer"))
end

function CombatDamageService.Start(self: Module)
    
end

return CombatDamageService :: Module
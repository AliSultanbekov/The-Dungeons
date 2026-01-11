--[=[
    @class CombatServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatServiceClient = {}

-- [ Types ] --
type ClientAbilityData = CombatTypes.ClientAbilityData
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceClient: typeof(require("NetworkServiceClient"))
}

export type Module = typeof(CombatServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatServiceClient.UseBasicAttack(self: Module, abilityData: ClientAbilityData)
    local Network = self._NetworkServiceClient:GetNetwork("CombatService")
    Network:FireServer("UseBasicAttack", abilityData)
end

function CombatServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceClient = self._ServiceBag:GetService(require("NetworkServiceClient"))
end

function CombatServiceClient.Start(self: Module)
    
end

return CombatServiceClient :: Module
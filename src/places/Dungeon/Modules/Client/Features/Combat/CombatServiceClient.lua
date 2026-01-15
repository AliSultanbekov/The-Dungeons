--[=[
    @class CombatServiceClient
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
local CombatServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceClient: typeof(require("NetworkServiceClient"))
}

export type Module = typeof(CombatServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatServiceClient.UseAbility(self: Module, params: {[any]: any}?)
    local Network = self._NetworkServiceClient:GetNetwork("CombatService")
    Network:FireServer("UseAbility", params)
end

function CombatServiceClient.HitTarget(self: Module, params: {[any]: any}?)
    local Network = self._NetworkServiceClient:GetNetwork("CombatService")
    Network:FireServer("HitTarget", params)
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
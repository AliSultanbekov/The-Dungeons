--[=[
    @class CombatServiceClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local CombatServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceClient: typeof(require("NetworkServiceClient")),
    PublicSignals: {
        AbilityUsed: Signal.Signal<{[any]: any}?>,
        AbilityEnded: Signal.Signal<{[any]: any}?>,
        AbilityHit: Signal.Signal<{[any]: any}?>,
    }
}

export type Module = typeof(CombatServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatServiceClient.UseAbility(self: Module, params: {[any]: any}?)
    local Network = self._NetworkServiceClient:GetNetwork("CombatService")
    Network:FireServer("UseAbility", params)
end

function CombatServiceClient.EndAbility(self: Module, params: {[any]: any}?)
    local Network = self._NetworkServiceClient:GetNetwork("CombatService")
    Network:FireServer("EndAbility", params)
end

function CombatServiceClient.HitAbility(self: Module, params: {[any]: any}?)
    local Network = self._NetworkServiceClient:GetNetwork("CombatService")
    Network:FireServer("HitAbility", params)
end

function CombatServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceClient = self._ServiceBag:GetService(require("NetworkServiceClient"))
    self.PublicSignals = {
        AbilityUsed = Signal.new() :: any,
        AbilityEnded = Signal.new() :: any,
        AbilityHit = Signal.new() :: any
    }
end

function CombatServiceClient.Start(self: Module)
    local Network = self._NetworkServiceClient:GetNetwork("CombatService")

    Network:Connect("AbilityUsed", function(params: {[any]: any}?)
        if not params then
            return
        end

        if params.Attacker == Player.Character then
            return
        end

        self.PublicSignals.AbilityUsed:Fire(params)
    end)

    Network:Connect("AbilityEnded", function(params: {[any]: any}?)
        if not params then
            return
        end

        if params.Attacker == Player.Character then
            return
        end

        self.PublicSignals.AbilityEnded:Fire(params)
    end)

    Network:Connect("AbilityHit", function(params: {[any]: any}?)
        if not params then
            return
        end

        if params.Attacker == Player.Character then
            return
        end
        
        self.PublicSignals.AbilityHit:Fire(params)
    end)
end

return CombatServiceClient :: Module
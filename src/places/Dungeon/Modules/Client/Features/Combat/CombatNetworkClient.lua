--[=[
    @class CombatNetworkClient
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
local CombatNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
    RemoteEvents: {
        AbilityUsed: Signal.Signal<{[any]: any}?>,
        AbilityEnded: Signal.Signal<{[any]: any}?>,
        AbilityHit: Signal.Signal<{[any]: any}?>,
    }
}

export type Module = typeof(CombatNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatNetworkClient.UseAbility(self: Module, params: {[any]: any}?)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireServer("UseAbility", params)
end

function CombatNetworkClient.EndAbility(self: Module, params: {[any]: any}?)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireServer("EndAbility", params)
end

function CombatNetworkClient.HitAbility(self: Module, params: {[any]: any}?)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireServer("HitAbility", params)
end

function CombatNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(require("NetworkManager"))
    self.RemoteEvents = {
        AbilityUsed = Signal.new() :: any,
        AbilityEnded = Signal.new() :: any,
        AbilityHit = Signal.new() :: any
    }
end

function CombatNetworkClient.Start(self: Module)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")

    CombatChannel:Connect("AbilityUsed", function(params: {[any]: any}?)
        if not params then
            return
        end

        if params.Attacker == Player.Character then
            return
        end

        self.RemoteEvents.AbilityUsed:Fire(params)
    end)

    CombatChannel:Connect("AbilityEnded", function(params: {[any]: any}?)
        if not params then
            return
        end

        if params.Attacker == Player.Character then
            return
        end

        self.RemoteEvents.AbilityEnded:Fire(params)
    end)

    CombatChannel:Connect("AbilityHit", function(params: {[any]: any}?)
        if not params then
            return
        end

        if params.Attacker == Player.Character then
            return
        end
        
        self.RemoteEvents.AbilityHit:Fire(params)
    end)
end

return CombatNetworkClient :: Module
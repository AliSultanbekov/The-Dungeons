--[=[
    @class CombatNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatNetworkClient = {}

-- [ Types ] --
type Context = CombatTypes.Context

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkManager: typeof(require("NetworkManager")),
    RemoteEvents: {
        AbilityHit: Signal.Signal<CombatTypes.AbilityHitRemotePacket>,
        EntityStateUpdated: Signal.Signal<CombatTypes.EntityStateUpdatedRemotePacket>,
    }
}

export type Module = typeof(CombatNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatNetworkClient.UseAbility(self: Module, packet: CombatTypes.UseAbilityRemotePacket)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireServer("UseAbility", packet)
end

function CombatNetworkClient.EndAbility(self: Module, packet: CombatTypes.EndAbilityRemotePacket)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireServer("EndAbility", packet)
end

function CombatNetworkClient.HitAbility(self: Module, packet: CombatTypes.HitAbilityRemotePacket)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")
    CombatChannel:FireServer("HitAbility", packet)
end

function CombatNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkManager = self._ServiceBag:GetService(require("NetworkManager"))
    self.RemoteEvents = {
        AbilityHit = Signal.new(),
        EntityStateUpdated = Signal.new(),
    } :: any
end

function CombatNetworkClient.Start(self: Module)
    local CombatChannel = self._NetworkManager:GetNetwork("Combat")

    CombatChannel:Connect("AbilityHit", function(packet: CombatTypes.AbilityHitRemotePacket)
        self.RemoteEvents.AbilityHit:Fire(packet)
    end)

    CombatChannel:Connect("EntityStateUpdated", function(packet: CombatTypes.EntityStateUpdatedRemotePacket)  
        self.RemoteEvents.EntityStateUpdated:Fire(packet)
    end)
end

return CombatNetworkClient :: Module
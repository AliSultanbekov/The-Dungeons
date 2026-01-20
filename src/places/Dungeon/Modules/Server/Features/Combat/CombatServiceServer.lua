--[=[
    @class CombatServiceServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local AbilityManager = require("AbilityManager")
local CombatClass = require("CombatClass")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatServiceServer = {}

-- [ Types ] --
type CombatObject = CombatClass.Object
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatNetworkServer: typeof(require("CombatNetworkServer")),
    _PlayerCharacterManager: typeof(require("PlayerCharacterManager")),
    _PositionHistoryService: typeof(require("PositionHistoryService")),
    _AbilityManager: AbilityManager.Object,
    _CombatObjects: { [Model]: CombatObject},
}

export type Module = typeof(CombatServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatServiceServer.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    local CombatObject = CombatClass.new(character, self._AbilityManager)
    CombatObject:AddAbility("DefaultBasicAttack", { 
        ItemData = { Name = "Wooden Sword" }, 
        PositionHistoryService = self._PositionHistoryService
    })

    self._CombatObjects[character] = CombatObject

    maid:Add(function()
        self._CombatObjects[character] = nil
    end)
end

function CombatServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatNetworkServer = self._ServiceBag:GetService(require("CombatNetworkServer"))
    self._PlayerCharacterManager = self._ServiceBag:GetService(require("PlayerCharacterManager"))
    self._PositionHistoryService = self._ServiceBag:GetService(require("PositionHistoryService"))
    self._AbilityManager = AbilityManager.new(script.Parent.Abilities)
    self._CombatObjects = {}
end

function CombatServiceServer.Start(self: Module)
    self._PlayerCharacterManager:RegisterModule(self)

    self._CombatNetworkServer.RemoteEvents.UseAbility:Connect(function(player: Player, params: {[any]: any}?)
        local Character = player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        local Params: {[any]: any} = params or {}

        Params.Mode = "FromClient"
        Params.OnUsed = function(params)
            self._CombatNetworkServer:AbilityUsed(params)
        end

        CombatObject:UseAbility("DefaultBasicAttack", params)
    end)

    self._CombatNetworkServer.RemoteEvents.EndAbility:Connect(function(player: Player, params: {[any]: any}?)
        local Character = player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        local Params: {[any]: any} = params or {}

        Params.Mode = "FromClient"
        Params.OnEnded = function(params)
            self._CombatNetworkServer:AbilityEnded(params)
        end

        CombatObject:EndAbility("DefaultBasicAttack", params)
    end)

    self._CombatNetworkServer.RemoteEvents.HitAbility:Connect(function(player: Player, params: {[any]: any}?)
        local Character = player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        local Params: {[any]: any} = params or {}

        Params.Mode = "FromClient"
        Params.OnHit = function(params)
            self._CombatNetworkServer:AbilityHit(params)
        end

        CombatObject:HitAbility("DefaultBasicAttack", Params)
    end)
end

return CombatServiceServer :: Module
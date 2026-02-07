--[=[
    @class CombatServiceServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local AbilityManager = require("AbilityManager")
local CombatClass = require("CombatClass")
local CombatTypes = require("CombatTypes")
local CreatureTypesServer = require("CreatureTypesServer")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatServiceServer = {}

-- [ Types ] --
type CombatObject = CombatClass.Object
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatNetworkServer: typeof(require("CombatNetworkServer")),
    _CreatureServiceServer: typeof(require("CreatureServiceServer")),
    _AbilityManager: AbilityManager.Object,
    _CombatObjects: { [Model]: CombatObject},
}

export type Module = typeof(CombatServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatNetworkServer = self._ServiceBag:GetService(require("CombatNetworkServer"))
    self._CreatureServiceServer = self._ServiceBag:GetService(require("CreatureServiceServer"))
    self._AbilityManager = AbilityManager.new(script.Parent.Abilities)
    self._CombatObjects = {}
end

function CombatServiceServer.Start(self: Module)
    self._CombatNetworkServer.RemoteEvents.UseAbility:Connect(function(player: Player, context: CombatTypes.Context?)
        if not context then
            return
        end

        local Character = player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        context.Mode = "FromClient"

        CombatObject:UseAbility(context.AbilityName, context)
    end)

    self._CombatNetworkServer.RemoteEvents.EndAbility:Connect(function(player: Player, context: CombatTypes.Context?)
        if not context then
            return
        end
        
        local Character = player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        context.Mode = "FromClient"

        CombatObject:EndAbility(context.AbilityName, context)
    end)

    self._CombatNetworkServer.RemoteEvents.HitAbility:Connect(function(player: Player, context: CombatTypes.Context?)
        if not context then
            return
        end

        local Character = player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        context.Mode = "FromClient"

        CombatObject:HitAbility(context.AbilityName, context)
    end)

    self._CreatureServiceServer.PublicSignals.CreatureCreated:Connect(function(character: Model)
        local CombatObject = CombatClass.new(character, {
            ServiceBag = self._ServiceBag,
            AbilityManager = self._AbilityManager,

            OnUse = function(context: CombatTypes.Context)
                
            end,
            OnEnd = function(context: CombatTypes.Context)
                
            end,
            OnHit = function(context: CombatTypes.Context)
                self._CombatNetworkServer:AbilityHit(context)
            end,
        })
        CombatObject:AddAbility("DefaultBasicAttack", { 
            ItemData = { Name = "Wooden Sword" },
        })
        CombatObject:AddAbility("Block", { 
            ItemData = { Name = "Wooden Sword" },
        })
        CombatObject:AddAbility("Parry", { 
            ItemData = { Name = "Wooden Sword" },
        })
    
        self._CombatObjects[character] = CombatObject
    end)

    self._CreatureServiceServer.PublicSignals.CreatureDeleted:Connect(function(character: Model)
        self._CombatObjects[character] = nil
    end)

    self._CreatureServiceServer.PublicSignals.AbilityExpired:Connect(function(packet: CreatureTypesServer.AbilityExpiredSignalPacket)
        local CombatObject = self._CombatObjects[packet.Character]

        if not CombatObject then
            return
        end

        CombatObject:EndAbility(packet.AbilityData.AbilityName, {
            Mode = "FromECS"
        })
    end)
end

return CombatServiceServer :: Module
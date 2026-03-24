--[=[
    @class CombatController
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local CombatKeybinds = require("./_CombatKeybinds")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local AbilityManager = require("AbilityManager")
local CombatClass = require("CombatClass")
local CombatTypes = require("CombatTypes")
local CreatureTypesClient = require("CreatureTypesClient")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local CombatController = {}

-- [ Types ] --
type CombatObject = CombatClass.Object
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UserInputManager: typeof(require("UserInputManager")),
    _CombatNetworkClient: typeof(require("CombatNetworkClient")),
    _CreatureServiceClient: typeof(require("CreatureServiceClient")),
    _EntityServiceClient: typeof(require("EntityServiceClient")),
    _AbilityManager: AbilityManager.Object,
    _CombatObjects: {
        [Model]: CombatObject
    },
    _AbilityBuffer: {
        AbilityName: string,
        ActionName: string,
        Cb: () -> (),
    }?
}

export type Module = typeof(CombatController) & ModuleData

-- [ Private Functions ] --
function CombatController._SetupKeybinds(self: Module)
    local Actions = CombatKeybinds.Actions
    local KeyMaps = CombatKeybinds.KeyMaps

    self._UserInputManager:RegisterKeymapAction(Actions.BASIC_ATTACK, KeyMaps[Actions.BASIC_ATTACK], function(data)
        if data.InputState == Enum.UserInputState.Begin then
            local Cb = function()
                local Character = Player.Character
    
                if not Character then
                    return
                end
        
                local CombatObject = self._CombatObjects[Character]
        
                CombatObject:UseAbility("DefaultBasicAttack", { Mode = "FromClient" })
            end
            
            self._AbilityBuffer = {
                AbilityName = "DefaultBasicAttack",
                ActionName = Actions.BASIC_ATTACK,
                Cb = Cb,
            }

            Cb()
        elseif data.InputState == Enum.UserInputState.End then
            if self._AbilityBuffer and self._AbilityBuffer.ActionName == Actions.BASIC_ATTACK then
                self._AbilityBuffer = nil
            end
        end
    end)

    self._UserInputManager:RegisterKeymapAction(Actions.BLOCK, KeyMaps[Actions.BLOCK], function(data)
        local Character = Player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]
        
        if data.InputState == Enum.UserInputState.Begin then
            local Cb = function()
                CombatObject:UseAbility("Block", { Mode = "FromClient" })
                CombatObject:UseAbility("Parry", { Mode = "FromClient" })
            end

            self._AbilityBuffer = {
                AbilityName = "Block",
                ActionName = Actions.BLOCK,
                Cb = Cb,
            }

            Cb()
        elseif data.InputState == Enum.UserInputState.End then
            if self._AbilityBuffer and self._AbilityBuffer.ActionName == Actions.BLOCK then
                self._AbilityBuffer = nil
            end
            
            CombatObject:EndAbility("Block", { Mode = "FromClient" })
            CombatObject:EndAbility("Parry", { Mode = "FromClient" })
        end
    end)

    self._UserInputManager:RegisterKeymapAction(Actions.DASH, KeyMaps[Actions.DASH], function(data)
        if data.InputState == Enum.UserInputState.Begin then
            local Cb = function()
                local Character = Player.Character

                if not Character then
                    return
                end
        
                local CombatObject = self._CombatObjects[Character]
        
                CombatObject:UseAbility("Dash", { Mode = "FromClient" })
            end

            self._AbilityBuffer = {
                AbilityName = "Dash",
                ActionName = Actions.DASH,
                Cb = Cb,
            }

            Cb()
        elseif data.InputState == Enum.UserInputState.End then
            if self._AbilityBuffer and self._AbilityBuffer.ActionName == Actions.DASH then
                self._AbilityBuffer = nil
            end
        end
    end)
end

function CombatController._UseAbilityBuffer(self: Module)
    if not self._AbilityBuffer then
        print("Returned")
        return
    end

    local Character = Player.Character

    if not Character then
        print("Returned 2")
        return
    end

    self._AbilityBuffer.Cb()

    if self._AbilityBuffer and not self._CreatureServiceClient:GetCurrentAbility(Character, self._AbilityBuffer.AbilityName) then
        task.delay(0.05, function()
            if not self._AbilityBuffer then
                return
            end

            self:_UseAbilityBuffer()
        end)
    end
end

-- [ Public Functions ] --

function CombatController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UserInputManager = self._ServiceBag:GetService(require("UserInputManager"))
    self._CombatNetworkClient = self._ServiceBag:GetService(require("CombatNetworkClient"))
    self._CreatureServiceClient = self._ServiceBag:GetService(require("CreatureServiceClient"))

    self._AbilityManager = AbilityManager.new(script.Parent.Abilities)
    self._CombatObjects = {}
    self._AbilityBuffer = nil
end

function CombatController.Start(self: Module)
    self._CombatNetworkClient.RemoteEvents.AbilityHit:Connect(function(context: CombatTypes.Context?)
        if not context then
            return
        end

        local Attacker = context.Attacker
        local CombatObject = self._CombatObjects[Attacker]

        context.Mode = "FromServer"

        CombatObject:HitAbility("DefaultBasicAttack", context)
    end)

    self._CreatureServiceClient.PublicSignals.CreatureCreated:Connect(function(packet: CreatureTypesClient.CreatureCreatedSignalPacket)
        local CombatObject = CombatClass.new(packet.Character, {
            ServiceBag = self._ServiceBag,
            AbilityManager = self._AbilityManager,
    
            OnUse = function(context: CombatTypes.Context)
                self._CombatNetworkClient:UseAbility(context)
            end,
            OnEnd = function(context: CombatTypes.Context)
                self._CombatNetworkClient:EndAbility(context)
                self:_UseAbilityBuffer()
            end,
            OnHit = function(context: CombatTypes.Context)
                self._CombatNetworkClient:HitAbility(context)
            end,
        })
        CombatObject:AddAbility("DefaultBasicAttack", { 
            ItemData = { Name = "Wooden Sword" },
        })
        CombatObject:AddAbility("Block", { 
            ItemData = { Name = "Wooden Sword" },
        })
        CombatObject:AddAbility("Dash", { 
            ItemData = { Name = "Wooden Sword" },
        })
        CombatObject:AddAbility("Parry", { 
            ItemData = { Name = "Wooden Sword" },
        })
    
        self._CombatObjects[packet.Character] = CombatObject
    end)

    self._CreatureServiceClient.PublicSignals.CreatureDeleted:Connect(function(packet: CreatureTypesClient.CreatureDeletedSignalPacket)
        self._CombatObjects[packet.Character] = nil
    end)

    self._CreatureServiceClient.PublicSignals.AbilityExpired:Connect(function(packet: CreatureTypesClient.AbilityExpiredSignalPacket)
        local CombatObject = self._CombatObjects[packet.Character]

        if not CombatObject then
            return
        end

        CombatObject:EndAbility(packet.AbilityData.AbilityName, {
            Mode = "FromECS"
        })

        self:_UseAbilityBuffer()
    end)

    self:_SetupKeybinds()
end

return CombatController :: Module
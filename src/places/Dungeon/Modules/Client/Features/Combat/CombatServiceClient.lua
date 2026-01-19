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
local Maid = require("Maid")
local AbilityManager = require("AbilityManager")
local CombatClass = require("CombatClass")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local CombatController = {}

-- [ Types ] --
type CombatObject = CombatClass.Object
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PlayerCharacterManager: typeof(require("PlayerCharacterManager")),
    _UserInputManager: typeof(require("UserInputManager")),
    _CombatNetworkClient: typeof(require("CombatNetworkClient")),
    _AbilityManager: AbilityManager.Object,
    _CombatObjects: {
        [Model]: CombatObject
    }
}

export type Module = typeof(CombatController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatController.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    local CombatObject = CombatClass.new(character, self._AbilityManager)
    CombatObject:AddAbility("DefaultBasicAttack", { ItemData = { Name = "Wooden Sword" } })

    self._CombatObjects[character] = CombatObject

    maid:Add(function()
        self._CombatObjects[character] = nil
    end)
end

function CombatController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PlayerCharacterManager = self._ServiceBag:GetService(require("PlayerCharacterManager"))
    self._UserInputManager = self._ServiceBag:GetService(require("UserInputManager"))
    self._CombatNetworkClient = self._ServiceBag:GetService(require("CombatNetworkClient"))

    self._AbilityManager = AbilityManager.new(script.Parent.Abilities)
    self._CombatObjects = {}
end

function CombatController.Start(self: Module)
    self._PlayerCharacterManager:RegisterModule(self)
    
    local Actions = CombatKeybinds.Actions
    local KeyMaps = CombatKeybinds.KeyMaps

    self._UserInputManager:RegisterKeymapAction(Actions.BASIC_ATTACK, KeyMaps[Actions.BASIC_ATTACK], function(data)
        if data.InputState ~= Enum.UserInputState.Begin then
            return
        end

        local Character = Player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        CombatObject:UseAbility("DefaultBasicAttack",
            {
                Mode = "FromClient",
                OnUse = function(params: {[any]: any}?)
                    self._CombatNetworkClient:UseAbility(params)
                end,
                OnEnd = function(params: {[any]: any}?)
                    self._CombatNetworkClient:EndAbility(params)
                end,
                OnHit = function(params: {[any]: any}?)
                    self._CombatNetworkClient:HitAbility(params)
                end,
            }
        )
    end)

    self._CombatNetworkClient.RemoteEvents.AbilityHit:Connect(function(params: { [any]: any }?)
        if not params then
            return
        end

        local Attacker = params.Attacker
        local CombatObject = self._CombatObjects[Attacker]
        CombatObject:HitAbility("DefaultBasicAttack", params)
    end)
end

return CombatController :: Module
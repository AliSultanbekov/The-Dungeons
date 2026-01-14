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
    _PlayerCharacterController: typeof(require("PlayerCharacterController")),
    _UserInputController: typeof(require("UserInputController")),
    _CombatServiceClient: typeof(require("CombatServiceClient")),
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
    self._PlayerCharacterController = self._ServiceBag:GetService(require("PlayerCharacterController"))
    self._UserInputController = self._ServiceBag:GetService(require("UserInputController"))
    self._CombatServiceClient = self._ServiceBag:GetService(require("CombatServiceClient"))

    self._AbilityManager = AbilityManager.new(script.Parent.Abilities)
    self._CombatObjects = {}
end

function CombatController.Start(self: Module)
    self._PlayerCharacterController:RegisterService(self)
    
    local Actions = CombatKeybinds.Actions
    local KeyMaps = CombatKeybinds.KeyMaps

    self._UserInputController:RegisterKeymapAction(Actions.BASIC_ATTACK, KeyMaps[Actions.BASIC_ATTACK], function(data)
        if data.InputState ~= Enum.UserInputState.Begin then
            return
        end

        local Character = Player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        CombatObject:UseAbility(
            "DefaultBasicAttack",
            {
                Mode = "Prediction",
                OnHit = function(hitCharacter: Model)
                    
                end
            }
        )
        
        self._CombatServiceClient:UseAbility()
    end)
end

return CombatController :: Module
--[=[
    @class CombatController
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local AbilityManagerClient = require("./_AbilityManagerClient")
local CombatClassClient = require("./_CombatClassClient")
local CombatKeyBinds = require("./_CombatKeybinds")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local CombatController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UserInputController: typeof(require("UserInputController")),
    _PlayerCharacterController: typeof(require("PlayerCharacterController")),
    _AbilityManagerClient: AbilityManagerClient.Object,
    _CombatObjectsClient: { [Model]: CombatClassClient.Object },
}

export type Module = typeof(CombatController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatController.OnCharacterAdded(self: Module, character: Model)
    print(character)
    local CombatObjectClient = CombatClassClient.new(character, self._AbilityManagerClient)
    self._CombatObjectsClient[character] = CombatObjectClient
end

function CombatController.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    self:OnCharacterAdded(character)

    maid:Add(function()
        self._CombatObjectsClient[character] = nil
    end)
end

function CombatController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UserInputController = self._ServiceBag:GetService(require("UserInputController"))
    self._PlayerCharacterController = self._ServiceBag:GetService(require("PlayerCharacterController"))
    self._AbilityManagerClient = AbilityManagerClient.new()
    self._CombatObjectsClient = {}
end

function CombatController.Start(self: Module)
    self._PlayerCharacterController:RegisterService(self)

    local Actions = CombatKeyBinds.Actions
    local KeyMaps = CombatKeyBinds.KeyMaps

    self._UserInputController:RegisterKeymapAction(Actions.BASIC_ATTACK, KeyMaps[Actions.BASIC_ATTACK], function(data)
        if data.InputState ~= Enum.UserInputState.Begin then
            return
        end

        local Character = Player.Character

        if not Character then
            return
        end

        local CombatObjectClient = self._CombatObjectsClient[Character]

        CombatObjectClient:UseBasicAttack()
    end)

    task.spawn(function()
        task.wait(3)
        local Character = Player.Character

        if not Character then
            return
        end

        local CombatObjectClient = self._CombatObjectsClient[Character]

        CombatObjectClient:SetActiveWeapon("Wooden Sword")
    end)
end

return CombatController :: Module
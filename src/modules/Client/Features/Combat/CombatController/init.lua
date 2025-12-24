--[=[
    @class CombatController
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local CombatKeyMap = require("@self/_CombatKeyMap")

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
    _WeaponController: typeof(require("WeaponController")),
    _Maid: Maid.Maid,
}

export type Module = typeof(CombatController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UserInputController = self._ServiceBag:GetService(require("UserInputController"))
    self._WeaponController = self._ServiceBag:GetService(require("WeaponController"))

    self._Maid = Maid.new()
end

function CombatController.Start(self: Module)
    local Actions = CombatKeyMap.Actions

    self._Maid:GiveTask(self._UserInputController:RegisterKeymapAction(
        Actions.WEAPON_PRIMARY,
        CombatKeyMap.KeyMaps[Actions.WEAPON_PRIMARY],
        function(packet)
            if packet.InputState ~= Enum.UserInputState.Begin then
                return
            end

            local Character = Player.Character

            local Tool = Character:FindFirstChildOfClass("Tool")

            self._WeaponController:Attack(Tool.Name)
        end
    ))
end

return CombatController :: Module
--[=[
    @class CombatService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local CombatClass = require("./_CombatClass")
local AbilityManager = require("./_AbilityManager")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local CombatTypes = require("CombatTypes")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatService = {}

-- [ Types ] --
type ClientAbilityData = CombatTypes.ClientAbilityData
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkService: typeof(require("NetworkService")),
    _PlayerCharacterService: typeof(require("PlayerCharacterService")),
    _AbilityManager: AbilityManager.Object,
    _CombatObjects: { [Model]: CombatClass.Object }
}

export type Module = typeof(CombatService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatService.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    local CombatObject = CombatClass.new(character, self._AbilityManager)

    self._CombatObjects[character] = CombatObject

    maid:Add(function()
        self._CombatObjects[character] = nil
    end)
end

function CombatService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkService = self._ServiceBag:GetService(require("NetworkService"))
    self._PlayerCharacterService = self._ServiceBag:GetService(require("PlayerCharacterService"))
    self._AbilityManager = AbilityManager.new()
    self._CombatObjects = {}
end

function CombatService.Start(self: Module)
    self._PlayerCharacterService:RegisterService(self)
    local Network = self._NetworkService:GetNetwork("CombatService")

    -- Client
    Network:DeclareEvent("UseBasicAttack")
    Network:DeclareEvent("UseSpecialAttack")
    
    Network:Connect("UseBasicAttack", function(player: Player, abilityData: ClientAbilityData)
        local Character = player.Character
        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]
        CombatObject:UseBasicAttack(abilityData)
    end)

    task.spawn(function()
        task.wait(3)
        local Character = Players:GetChildren()[1].Character

        if not Character then
            return
        end

        local CombatObjectClient = self._CombatObjects[Character]

        CombatObjectClient:SetActiveWeapon("Wooden Sword")
    end)
end

return CombatService :: Module
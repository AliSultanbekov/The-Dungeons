--[=[
    @class CombatService
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
local CombatService = {}

-- [ Types ] --
type CombatObject = CombatClass.Object
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PlayerCharacterService: typeof(require("PlayerCharacterService")),
    _NetworkService: typeof(require("NetworkService")),
    _PositionHistoryService: typeof(require("PositionHistoryService")),
    _AbilityManager: AbilityManager.Object,
    _CombatObjects: { [Model]: CombatObject},
}

export type Module = typeof(CombatService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatService.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
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

function CombatService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PlayerCharacterService = self._ServiceBag:GetService(require("PlayerCharacterService"))
    self._NetworkService = self._ServiceBag:GetService(require("NetworkService"))
    self._PositionHistoryService = self._ServiceBag:GetService(require("PositionHistoryService"))
    self._AbilityManager = AbilityManager.new(script.Parent.Abilities)
    self._CombatObjects = {}
end

function CombatService.Start(self: Module)
    self._PlayerCharacterService:RegisterService(self)

    local Network = self._NetworkService:GetNetwork("CombatService")
    
    -- client
    Network:DeclareEvent("UseAbility")
    Network:DeclareEvent("HitTarget")
    -- server
    Network:DeclareEvent("AbilityUsed")
    Network:DeclareEvent("TargetHit")

    Network:Connect("UseAbility", function(player: Player, params: {[any]: any}?)
        local Character = player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        CombatObject:UseAbility("DefaultBasicAttack", params)
    end)

    Network:Connect("HitTarget", function(player: Player, params: {[any]: any}?)  
        local Character = player.Character

        if not Character then
            return
        end

        local CombatObject = self._CombatObjects[Character]

        local Params: {[any]: any} = params or {}

        Params.Mode = "FromClient"

        CombatObject:ApplyAbility("DefaultBasicAttack", Params)
    end)
end

return CombatService :: Module
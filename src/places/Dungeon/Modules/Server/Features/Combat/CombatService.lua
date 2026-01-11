--[=[
    @class CombatService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatService = {}

-- [ Types ] --
type ClientAbilityData = CombatTypes.ClientAbilityData
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkService: typeof(require("NetworkService")),
}

export type Module = typeof(CombatService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkService = self._ServiceBag:GetService(require("NetworkService"))
end

function CombatService.Start(self: Module)
    print("SSs")
    local Network = self._NetworkService:GetNetwork("CombatService")

    -- Client
    Network:DeclareEvent("UseBasicAttack")
    Network:DeclareEvent("UseSpecialAttack")
    
    Network:Connect("UseBasicAttack", function(player: Player, abilityData: ClientAbilityData)
        print(abilityData)
    end)
end

return CombatService :: Module
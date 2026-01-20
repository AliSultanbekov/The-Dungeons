--[=[
    @class CombatStateService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatStateService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatEntityService: typeof(require("CombatEntityService"))
}

export type Module = typeof(CombatStateService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatStateService.StartBlocking(self: Module, entity: Jecs.Entity)
    local World = self._CombatEntityService:GetWorld()
    local Components = self._CombatEntityService:GetComponents()

    if World:has(entity, Components.Stunned) then
        return
    end

    local Ether = World:get(entity, Components.Ether)

    if not Ether then
        return
    end

    if Ether <= 0 then
        return
    end

    World:set(entity, Components.Blocking, {
        StartTime = os.clock()
    })
end

function CombatStateService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatEntityService = self._ServiceBag:GetService(require("CombatEntityService"))
end

function CombatStateService.Start(self: Module)
    
end

return CombatStateService :: Module
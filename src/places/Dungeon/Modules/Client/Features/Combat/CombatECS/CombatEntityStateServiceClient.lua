--[=[
    @class CombatEntityStateServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("./_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local GetEntityFromCharacter = require("GetEntityFromCharacter")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatEntityStateServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatEntityServiceClient: typeof(require("CombatEntityServiceClient"))
}

export type Module = typeof(CombatEntityStateServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatEntityStateServiceClient.GetPreviousAbility(self: Module, character: Model): { [string]: any }?
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceClient:GetWorld()
    local Components = self._CombatEntityServiceClient:GetComponents()

    if not World:has(Entity, Components.PreviousAbility) then
        return
    end

    local PreviousAbility = World:get(Entity, Components.PreviousAbility) :: Types.PreviousAbilityComponent

    return table.clone(PreviousAbility)
end

function CombatEntityStateServiceClient.GetCurrentAbility(self: Module, character: Model): { [string]: any }?
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceClient:GetWorld()
    local Components = self._CombatEntityServiceClient:GetComponents()

    if not World:has(Entity, Components.CurrentAbility) then
        return
    end

    local CurrentAbility = World:get(Entity, Components.CurrentAbility) :: Types.CurrentAbilityComponent

    return table.clone(CurrentAbility)
end

function CombatEntityStateServiceClient.SetCurrentAbility(self: Module, character: Model, data: { [string]: any }?)
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceClient:GetWorld()
    local Components = self._CombatEntityServiceClient:GetComponents()

    if data then
        World:set(Entity, Components.CurrentAbility, data)
    else
        local CurrentAbility = World:get(Entity, Components.CurrentAbility)

        if not CurrentAbility then
            return
        end

        World:set(Entity, Components.PreviousAbility, table.clone(CurrentAbility))
        World:remove(Entity, Components.CurrentAbility)
    end
end

function CombatEntityStateServiceClient.IsStunned(self: Module, character: Model): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceClient:GetWorld()
    local Components = self._CombatEntityServiceClient:GetComponents()

    if World:has(Entity, Components.Stunned) then
        return true
    else
        return false
    end
end

function CombatEntityStateServiceClient.StartBlocking(self: Module, character: Model): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceClient:GetWorld()
    local Components = self._CombatEntityServiceClient:GetComponents()

    if World:has(Entity, Components.Stunned) then
        return false
    end

    local Ether = World:get(Entity, Components.Ether)

    if not Ether then
        return false
    end

    if Ether <= 0 then
        return false
    end

    World:set(Entity, Components.Blocking, {
        StartTime = os.clock()
    })

    return true
end

function CombatEntityStateServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatEntityServiceClient = self._ServiceBag:GetService(require("CombatEntityServiceClient"))
end

function CombatEntityStateServiceClient.Start(self: Module)

end

return CombatEntityStateServiceClient :: Module
--[=[
    @class CombatEntityStateServiceServer
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
local CombatEntityStateServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatEntityServiceServer: typeof(require("CombatEntityServiceServer"))
}

export type Module = typeof(CombatEntityStateServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatEntityStateServiceServer.DamageEntity(self: Module, attacker: Model, attacked: Model, damageNumber: number)
    if self:IsStunned(attacker) then
        return
    end

    local AttackerEntity = GetEntityFromCharacter(attacker)
    local AttackedEntity = GetEntityFromCharacter(attacked)
    local World = self._CombatEntityServiceServer:GetWorld()
    local Tags = self._CombatEntityServiceServer:GetTags()
    local Components = self._CombatEntityServiceServer:GetComponents()

    if not World:has(AttackedEntity, Tags.Alive) or not World:has(AttackerEntity, Tags.Alive) then  
        return
    end

    local Health = World:get(AttackedEntity, Components.Health)

    if not Health then
        return
    end

    if Health <= 0 then
        return
    end

    if Health - damageNumber <= 0 then
        damageNumber = Health
    end

    World:set(AttackedEntity, Components.Health, Health - damageNumber)
end

function CombatEntityStateServiceServer.GetPreviousAbility(self: Module, character: Model): { [string]: any }?
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceServer:GetWorld()
    local Components = self._CombatEntityServiceServer:GetComponents()

    if not World:has(Entity, Components.PreviousAbility) then
        return
    end

    local PreviousAbility = World:get(Entity, Components.PreviousAbility) :: Types.PreviousAbilityComponent

    return PreviousAbility
end

function CombatEntityStateServiceServer.GetCurrentAbility(self: Module, character: Model): { [string]: any }?
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceServer:GetWorld()
    local Components = self._CombatEntityServiceServer:GetComponents()

    if not World:has(Entity, Components.CurrentAbility) then
        return
    end

    local CurrentAbility = World:get(Entity, Components.CurrentAbility) :: Types.CurrentAbilityComponent

    return CurrentAbility
end

function CombatEntityStateServiceServer.TryUseAbility(self: Module, character: Model, abilityData: { [string]: any })
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceServer:GetWorld()
    --local Tag = self._CombatEntityServiceServer:GetTags()
    local Components = self._CombatEntityServiceServer:GetComponents()

    if World:has(Entity, Components.Stunned) then
        return false
    end

    if World:has(Entity, Components.CurrentAbility) then
        return false
    end

    local Ether = World:get(Entity, Components.Ether)

    if not Ether or Ether <= 0 then
        return false
    end

    World:set(Entity, Components.CurrentAbility, abilityData)

    if abilityData.AbilityName == "Block" then
        World:add(Entity, Components.Blocking)
    end

    return true
end

function CombatEntityStateServiceServer.TryEndAbility(self: Module, character, abilityName: string?): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceServer:GetWorld()
    --local Tag = self._CombatEntityServiceServer:GetTags()
    local Components = self._CombatEntityServiceServer:GetComponents()

    local CurrentAbility = World:get(Entity, Components.CurrentAbility)

    if not CurrentAbility then
        return false
    end

    if abilityName and CurrentAbility.AbilityName ~= abilityName then
        return false
    end

    World:set(Entity, table.clone(Components.PreviousAbility))
    World:remove(Entity, Components.CurrentAbility)

    if CurrentAbility.AbilityName == "Block" then
        World:remove(Entity, Components.Blocking)
    end

    return true
end

function CombatEntityStateServiceServer.IsStunned(self: Module, character: Model): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceServer:GetWorld()
    local Components = self._CombatEntityServiceServer:GetComponents()

    if World:has(Entity, Components.Stunned) then
        return true
    else
        return false
    end
end

function CombatEntityStateServiceServer.StartBlocking(self: Module, character: Model): boolean
    local Entity = GetEntityFromCharacter(character)
    local World = self._CombatEntityServiceServer:GetWorld()
    local Components = self._CombatEntityServiceServer:GetComponents()

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

    return true
end

function CombatEntityStateServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatEntityServiceServer = self._ServiceBag:GetService(require("CombatEntityServiceServer"))
end

function CombatEntityStateServiceServer.Start(self: Module)
    
end

return CombatEntityStateServiceServer :: Module
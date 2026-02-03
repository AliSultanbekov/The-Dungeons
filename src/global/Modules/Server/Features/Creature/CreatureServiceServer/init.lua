--[=[
    @class CreatureService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local CreatureRegister = require("@self/_CreatureRegister")
local CreatureAbility = require("@self/_CreatureAbility")
local CreatureDamage = require("@self/_CreatureDamage")
local CreatureGeneric = require("@self/_CreatureGeneric")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Jecs = require("Jecs")
local EntityTypesServer = require("EntityTypesServer")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureService = {}

-- [ Types ] --
type CreatureModule = {
    Init: (self: CreatureModule, entityServiceServer: EntityServiceServer) -> (),
    Start: (self: CreatureModule) -> (),
}
type EntityServiceServer = typeof(require("EntityServiceServer"))
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceServer: EntityServiceServer,
    _PlayerCharacterManager: typeof(require("PlayerCharacterManager")),
    _CreatureModules: {
        CreatureRegister: CreatureRegister.Module,
        CreatureAbility: CreatureAbility.Module,
        CreatureDamage: CreatureDamage.Module,
        CreatureGeneric: CreatureGeneric.Module
    }
}

export type Module = typeof(CreatureService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureService.DamageCreature(self: Module, attacker: Model, attacked: Model, damageAmount: number): string?
    local AttackerEntity = self:GetEntityFromCharacter(attacker)
    local AttackedEntity = self:GetEntityFromCharacter(attacked)

    if not AttackerEntity then
        return
    end

    if not AttackedEntity then
        return
    end

    return self._CreatureModules.CreatureDamage:DamageCreature(AttackerEntity, AttackedEntity, damageAmount)
end

function CreatureService.IsAbilityOnCooldown(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:IsAbilityOnCooldown(Entity, abilityName)
end

function CreatureService.StartAbilityCooldown(self: Module, character: Model, abilityName: string)
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    self._CreatureModules.CreatureAbility:StartAbilityCooldown(Entity, abilityName)
end

function CreatureService.IsAbilityActive(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:IsAbilityActive(Entity, abilityName)
end

function CreatureService.GetCurrentAbility(self: Module, character: Model): (EntityTypesServer.BaseAbilityComponent | EntityTypesServer.ComboAbilityComponent)?
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    return self._CreatureModules.CreatureAbility:GetCurrentAbility(Entity)
end

function CreatureService.GetPreviousAbility(self: Module, character: Model): (EntityTypesServer.BaseAbilityComponent | EntityTypesServer.ComboAbilityComponent)?
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    return self._CreatureModules.CreatureAbility:GetPreviousAbility(Entity)
end

function CreatureService.UseAbility(self: Module, character: Model, abilityData: EntityTypesServer.BaseAbilityComponent | EntityTypesServer.ComboAbilityComponent): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:UseAbility(Entity, abilityData)
end

function CreatureService.CancelAbility(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:CancelAbility(Entity, abilityName)
end

function CreatureService.EndAbility(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:EndAbility(Entity, abilityName)
end

function CreatureService.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CreatureModules.CreatureRegister:GetEntityFromCharacter(character)
end

function CreatureService.RegisterNPC(self: Module, character: Model)
    self._CreatureModules.CreatureRegister:RegisterNPC(character)
end

function CreatureService.RegisterPlayer(self: Module, character: Model)
    self._CreatureModules.CreatureRegister:RegisterPlayer(character)
end

function CreatureService.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    self:RegisterPlayer(character)
end

function CreatureService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceServer = self._ServiceBag:GetService(require("EntityServiceServer"))
    self._PlayerCharacterManager = self._ServiceBag:GetService(require("PlayerCharacterManager"))
    self._CreatureModules = {
        CreatureRegister = CreatureRegister,
        CreatureAbility = CreatureAbility,
        CreatureDamage = CreatureDamage,
        CreatureGeneric = CreatureGeneric,
    }

    for _, abilityModule in pairs(self._CreatureModules) do
        abilityModule:Init(self._EntityServiceServer)
    end
end

function CreatureService.Start(self: Module)
    self._PlayerCharacterManager:RegisterModule(self)

    for _, abilityModule in pairs(self._CreatureModules) do
        abilityModule:Start()
    end
end

return CreatureService :: Module
--[=[
    @class CreatureServiceServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local CreatureRegister = require("@self/_CreatureRegister")
local CreatureAbility = require("@self/_CreatureAbility")
local CreatureDamage = require("@self/_CreatureDamage")
local CreatureGeneric = require("@self/_CreatureGeneric")
local Types = require("./CreatureTypesServer")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Jecs = require("Jecs")
local EntityTypesServer = require("EntityTypesServer")
local Maid = require("Maid")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureServiceServer = {}

-- [ Types ] --
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
    },
    PublicSignals: Types.PublicSignals
}

export type Module = typeof(CreatureServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureServiceServer.DamageCreature(self: Module, attacker: Model, attacked: Model, damageAmount: number): string?
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

function CreatureServiceServer.IsAbilityOnCooldown(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:IsAbilityOnCooldown(Entity, abilityName)
end

function CreatureServiceServer.StartAbilityCooldown(self: Module, character: Model, abilityName: string, cooldownDuration: number?)
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    self._CreatureModules.CreatureAbility:StartAbilityCooldown(Entity, abilityName, cooldownDuration)
end

function CreatureServiceServer.IsAbilityActive(self: Module, character: Model, abilityName: string?): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:IsAbilityActive(Entity, abilityName)
end

function CreatureServiceServer.GetCurrentAbility(self: Module, character: Model, abilityName: string): (EntityTypesServer.BaseAbility | EntityTypesServer.ComboAbility)?
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    return self._CreatureModules.CreatureAbility:GetCurrentAbility(Entity, abilityName)
end

function CreatureServiceServer.GetPreviousAbility(self: Module, character: Model, abilityName: string): (EntityTypesServer.BaseAbility | EntityTypesServer.ComboAbility)?
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return
    end

    return self._CreatureModules.CreatureAbility:GetPreviousAbility(Entity, abilityName)
end

function CreatureServiceServer.UseAbility(self: Module, character: Model, abilityData: EntityTypesServer.BaseAbility | EntityTypesServer.ComboAbility): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:UseAbility(Entity, abilityData)
end

function CreatureServiceServer.CancelAbility(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:CancelAbility(Entity, abilityName)
end

function CreatureServiceServer.EndAbility(self: Module, character: Model, abilityName: string): boolean
    local Entity = self:GetEntityFromCharacter(character)

    if not Entity then
        return false
    end

    return self._CreatureModules.CreatureAbility:EndAbility(Entity, abilityName)
end

function CreatureServiceServer.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CreatureModules.CreatureRegister:GetEntityFromCharacter(character)
end

function CreatureServiceServer.RegisterNPC(self: Module, character: Model)
    self._CreatureModules.CreatureRegister:RegisterNPC(character)
end

function CreatureServiceServer.RegisterPlayer(self: Module, character: Model)
    self._CreatureModules.CreatureRegister:RegisterPlayer(character)
end

function CreatureServiceServer.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    self:RegisterPlayer(character)
end

function CreatureServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

    self.PublicSignals = {
        CreatureCreated = Signal.new(),
        CreatureDeleted = Signal.new(),
        AbilityExpired = Signal.new(),
    } :: any

    for _, creatureModule in pairs(self._CreatureModules) do
        creatureModule:Init({
            EntityServiceServer = self._EntityServiceServer,
            PublicSignals = self.PublicSignals
        })
    end
end

function CreatureServiceServer.Start(self: Module)
    self._PlayerCharacterManager:RegisterModule(self)

    for _, creatureModule in pairs(self._CreatureModules) do
        creatureModule:Start()
    end
end

return CreatureServiceServer :: Module
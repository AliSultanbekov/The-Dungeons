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
function CreatureService.DamageCreature(self: Module, Character: Model)
    local Entity = self:GetEntityFromCharacter(Character)

    if not Entity then
        return
    end


end

function CreatureService.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CreatureModules.CreatureRegister:GetEntityFromCharacter(character)
end

function CreatureService.RegisterNPC(self: Module, character: Model)
    self._CreatureModules.CreatureRegister:RegisterNPC(character)
end

function CreatureService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceServer = self._ServiceBag:GetService(require("EntityServiceServer"))
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
    
end

return CreatureService :: Module
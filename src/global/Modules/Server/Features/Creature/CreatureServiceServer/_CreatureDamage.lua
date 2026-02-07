--[=[
    @class CreatureDamage
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../CreatureTypesServer")

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local CombatConfig = require("CombatConfig")
local EntityTypesServer = require("EntityTypesServer")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureDamage = {}

-- [ Types ] --
type EntityServiceServer = typeof(require("EntityServiceServer"))
type ModuleData = {
    _EntityServiceServer: EntityServiceServer,
    PublicSignals: Types.PublicSignals
}

export type Module = typeof(CreatureDamage) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureDamage.DamageCreature(self: Module, attackerEntity: Jecs.Entity, attackedEntity: Jecs.Entity, damageAmount: number)
    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()
    local Components = self._EntityServiceServer:GetComponents()

    if not World:has(attackerEntity, Tags.Creature) or not World:has(attackedEntity, Tags.Creature) then
        return
    end

    if World:has(attackerEntity, Components.Stunned) then
        return
    end
    
    local AttackedHealth = World:get(attackedEntity, Components.Health)

    if not AttackedHealth or AttackedHealth <= 0 then
        return
    end

    local AttackedCurrentAbilities = World:get(attackedEntity, Components.CurrentAbilities)
    local AttackedBlockAbility = AttackedCurrentAbilities and AttackedCurrentAbilities["Block"]

    if AttackedBlockAbility then
        local AbilityCooldowns = World:get(attackedEntity, Components.AbilityCooldowns) :: EntityTypesServer.AbilityCooldownsComponent
        local ServerTime = workspace.DistributedGameTime
        local StartTime = AttackedBlockAbility.StartTime
        local DeltaTime = ServerTime - StartTime
        local CommitTime = AttackedBlockAbility.CommitTime :: number

        if not AbilityCooldowns["Parry"] then
            if CommitTime and DeltaTime > CommitTime and DeltaTime + CommitTime <= CombatConfig.ParryWindowTime then
                World:set(attackedEntity, Components.AbilityCooldowns, AbilityCooldowns)
                World:set(attackerEntity, Components.ParryStunned, ServerTime + 0.6)
                return "Parry"
            end
        end

        World:set(attackedEntity, Components.Health, math.max(0, (AttackedHealth - damageAmount)*0.6))
        return "Block"
    end

    World:set(attackedEntity, Components.Health, math.max(0, AttackedHealth - damageAmount))

    return "Hit"
end

function CreatureDamage.Init(self: Module, context: Types.Init_Context)
    self._EntityServiceServer = context.EntityServiceServer
    self.PublicSignals = context.PublicSignals
end

function CreatureDamage.Start(self: Module)
    
end

return CreatureDamage :: Module
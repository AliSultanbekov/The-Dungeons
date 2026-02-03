local ServerScriptService = game:GetService("ServerScriptService")
local Duration = require(ServerScriptService.Game.node_modules["@quentystudios"].Cmdr.BuiltInTypes.Duration)
--[=[
    @class CreatureDamage
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local CombatConfig = require("CombatConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureDamage = {}

-- [ Types ] --
type EntityServiceServer = typeof(require("EntityServiceServer"))
type ModuleData = {
    _EntityServiceServer: EntityServiceServer
}

export type Module = typeof(CreatureDamage) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureDamage.DamageCreature(self: Module, attackerEntity: Jecs.Entity, attackedEntity: Jecs.Entity, damageAmount: number)
    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()
    local Components = self._EntityServiceServer:GetComponents()

    if not World:has(attackerEntity, Tags.Alive) or not World:has(attackedEntity, Tags.Alive) then
        return
    end

    if World:has(attackerEntity, Components.Stunned) then
        return
    end
    
    local AttackedHealth = World:get(attackedEntity, Components.Health)

    if not AttackedHealth or AttackedHealth <= 0 then
        return
    end

    local AttackedCurrentAbility = World:get(attackedEntity, Components.CurrentAbility)

    if AttackedCurrentAbility and AttackedCurrentAbility.AbilityName == "Block" then
        local ServerTime = workspace.DistributedGameTime
        local StartTime = AttackedCurrentAbility.StartTime
        local DeltaTime = ServerTime - StartTime

        if DeltaTime <= CombatConfig.ParryWindowTime then
            World:set(attackedEntity, Components.ParryStunned, {
                StartTime = ServerTime,
                Duration = 0.25
            })
            return "Parry"
        end

        return "Block"
    end

    World:set(attackedEntity, Components.Health, math.max(0, AttackedHealth - damageAmount))

    return "Hit"
end

function CreatureDamage.Init(self: Module, entityServiceServer: EntityServiceServer)
    self._EntityServiceServer = entityServiceServer
end

function CreatureDamage.Start(self: Module)
    
end

return CreatureDamage :: Module
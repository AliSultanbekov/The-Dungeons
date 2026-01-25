--[=[
    @class ComponentConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local StatTypes = require("StatsTypes")
local GeneralGameConstants = require("GeneralGameConstants")
-- [ Constants ] --
local ECS_WORLD : Jecs.World = GeneralGameConstants.WORLD_ENTITY

-- [ Variables ] --

-- [ Module Table ] --
local ComponentConstants = {
    --Buffs
    HealthBuff = ECS_WORLD:component(),
    DamageBuff = ECS_WORLD:component(),
    SpeedBuff = ECS_WORLD:component(),
    MitigationBuff = ECS_WORLD:component(),
    
    --Debuffs
    HealthDebuff = ECS_WORLD:component(),
    DamageDebuff = ECS_WORLD:component(),
    SpeedDebuff = ECS_WORLD:component(),
    MitigationDebuff = ECS_WORLD:component(),
    
    --Misc
    CombatStats = ECS_WORLD:component() :: Jecs.Entity<StatTypes.PlayerStats>,
    Name = ECS_WORLD:component(),
    Prefab = ECS_WORLD:component(),

    --Combat Effects
    DamageOverTimeEffect = ECS_WORLD:component(),
    HealOverTimeEffect = ECS_WORLD:component(),
    InvinsibilityEffect = ECS_WORLD:component(),
    ShieldEffect = ECS_WORLD:component(),
    InvulnerabilityEffect = ECS_WORLD:component(),
    LifestealBuff = ECS_WORLD:component(),
    InCombatComponent = ECS_WORLD:component(),

    --Crowd Control
    StunEffect = ECS_WORLD:component(),
    RootEffect = ECS_WORLD:component(),
    SilenceEffect = ECS_WORLD:component(),
    FearEffect = ECS_WORLD:component(),
}

-- [ Types ] --
export type Module = typeof(ComponentConstants)

return ComponentConstants :: Module
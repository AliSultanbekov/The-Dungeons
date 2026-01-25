--[=[
    @class NPCHelperUtil
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")
-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local ComponentConstants = require("ComponentConstants")
local GeneralGameConstants = require("GeneralGameConstants")
local EnemyConfigs = require("EnemyConfigs")
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --
local _instance: Object? = nil

-- [ Module Table ] --
local NPCHelperUtil = {}
NPCHelperUtil.__index = NPCHelperUtil

-- [ Types ] --
export type ObjectData = {
    
}
export type Object = ObjectData & {
    _World: Jecs.World,
    _nameComp : Jecs.Id<string>,
    _characterStatsComp : Jecs.Id<any>,
    _npcPrefabComp : Jecs.Id<Instance>,
    
    CreateNewNPCEntity: (self: Object, npcName: string, prefab: any) -> number,
}
export type Module = {
    __index: Module,
    new: () -> Object,
    Get: () -> Object 
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function NPCHelperUtil.new(): Object
    local self = setmetatable({} :: any, NPCHelperUtil) :: Object
    self._World = GeneralGameConstants.WORLD_ENTITY
    
    self._nameComp = ComponentConstants.Name
    self._characterStatsComp = ComponentConstants.CombatStats
    self._npcPrefabComp = ComponentConstants.Prefab

    RunService.Heartbeat:Connect(function(a0: number)  
        for entity, prefab, stats in self._World:query(self._npcPrefabComp, self._characterStatsComp) do 
            (prefab.Humanoid :: Humanoid).MaxHealth = stats.RawStats.MaxHealth;
            (prefab.Humanoid :: Humanoid).Health = stats.RawStats.Health;
        end
    end)
    
    return self
end

function NPCHelperUtil.CreateNewNPCEntity(self : Object, npcName : string, prefab : any)    
    assert(EnemyConfigs[npcName], "NPC Config does not exist for "..npcName)

    local entity = self._World:entity()

    local characterStatsCalculated = EnemyConfigs[npcName]
    self._World:set(entity, self._nameComp, npcName)

    --//Contains raw and primary stats. Damage should be connected to rawstats.health
    self._World:set(entity, self._characterStatsComp, table.clone(characterStatsCalculated))

    --/3d prefab of the actual entity. 
    self._World:set(entity, self._npcPrefabComp, prefab)
    task.delay(5, function()
     
     self._World:set(entity, ComponentConstants.DamageOverTimeEffect, {
         Duration = 5,
         EffectTime = 0,
         Ticks = 5,
         EffectAmount = 2,
     })   
    end)
    return entity
end

-- Singleton getter
function NPCHelperUtil.Get(): Object
    if not _instance then
        _instance = NPCHelperUtil.new()
    end
    return _instance :: Object
end

return NPCHelperUtil :: Module
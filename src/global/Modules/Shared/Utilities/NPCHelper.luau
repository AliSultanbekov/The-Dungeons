--[=[
    @class NPCHelperUtil
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")
-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local GeneralGameConstants = require("GeneralGameConstants")
local EnemyConfigs = require("EnemyConfigs")
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

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
    
    CreateNewNPCEntity: (self: Object, npcName: string, prefab: Instance) -> number,
}
export type Module = {
    __index: Module,
    new: () -> Object 
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function NPCHelperUtil.new(): Object
    local self = setmetatable({} :: any, NPCHelperUtil) :: Object
    self._World = GeneralGameConstants.WORLD_ENTITY
    
    local characterStats = self._World:component()
    local name = self._World:component()
    local npcPrefab = self._World:component()
    
    self._nameComp = name
    self._characterStatsComp = characterStats
    self._npcPrefabComp = npcPrefab

    RunService.Heartbeat:Connect(function(a0: number)  
        for entity, prefab, stats in self._World:query(self._npcPrefabComp, self._characterStatsComp) do 
            warn("NPC Entity:", entity, "Prefab:", prefab, "Stats:", stats)
        end
    end)
    
    return self
end

function NPCHelperUtil.CreateNewNPCEntity(self : Object, npcName : string, prefab : Instance)    
    assert(EnemyConfigs[npcName], "NPC Config does not exist for "..npcName)

    local entity = self._World:entity()

    local characterStatsCalculated = EnemyConfigs[npcName]
    self._World:set(entity, self._nameComp, npcName)

    --//Contains raw and primary stats. Damage should be connected to rawstats.health
    self._World:set(entity, self._characterStatsComp, table.clone(characterStatsCalculated))

    --/3d prefab of the actual entity. 
    self._World:set(entity, self._npcPrefabComp, prefab)

    return entity
end

return NPCHelperUtil :: Module
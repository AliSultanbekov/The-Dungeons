--[=[
    @class CreatureSpawnService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local AssetProvider = require("AssetProvider")
local TimeUtil = require("TimeUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureSpawnService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CreatureServiceServer: typeof(require("CreatureServiceServer")),
}

export type Module = typeof(CreatureSpawnService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureSpawnService.SpawnNPC(self: Module, creatureName: string, position: Vector3): Model
    local CreatureModel = AssetProvider:Get("Objects/Creatures/" .. creatureName) :: Model?

    if not CreatureModel then
        error("[CreatureSpawnService] Creature not found: " .. creatureName)
    end

    local Character = CreatureModel:Clone()
    Character:PivotTo(CFrame.new(position))
    Character.Parent = workspace

    self._CreatureServiceServer:RegisterNPC(Character)

    return Character
end

function CreatureSpawnService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CreatureServiceServer = self._ServiceBag:GetService(require("CreatureServiceServer"))
end

function CreatureSpawnService.Start(self: Module)
    task.spawn(function()
        
        local Villager = self:SpawnNPC("Villager", Vector3.new(1,10,1))
        self._CreatureServiceServer:UseAbility(Villager, {
            AbilityName = "Block",
            StartTime = os.clock(),
            Duration = TimeUtil:GetTime(),
            IsHeld = true,
        })

        local Villager2 = self:SpawnNPC("Villager", Vector3.new(1,10,1))
        self._CreatureServiceServer:UseAbility(Villager2, {
            AbilityName = "Dash",
            StartTime = TimeUtil:GetTime(),
            Duration = math.huge,
        })
    
        local _Villager3 = self:SpawnNPC("Villager", Vector3.new(1,10,10))
    end)
end

return CreatureSpawnService :: Module

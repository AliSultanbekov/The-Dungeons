--[=[
    @class DamageBuffService
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local ComponentConstants = require("ComponentConstants")

local GeneralGameConstants = require("GeneralGameConstants")
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DamageBuffService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _JecsWorld: Jecs.World,
}

export type DamageBuff = {
    DamageMagnitde : number,
    Duration : number,
    ElapsedTime : number
}

export type Module = typeof(DamageBuffService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function DamageBuffService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._JecsWorld = GeneralGameConstants.WORLD_ENTITY
    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function DamageBuffService.Start(self: Module)
    RunService.Heartbeat:Connect(function(dt: number)  
        for entityId, damageBuff : DamageBuff in self._JecsWorld:query(ComponentConstants.DamageBuff) do 
            if damageBuff.ElapsedTime >= damageBuff.Duration then 
                self._JecsWorld:remove(entityId, ComponentConstants.DamageBuff)
            else
                damageBuff.ElapsedTime = damageBuff.ElapsedTime + dt
            end
        end
    end)
end

return DamageBuffService :: Module
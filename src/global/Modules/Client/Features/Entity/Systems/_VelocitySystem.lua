--[=[
    @class TestSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesClient = require("EntityTypesClient")
local Jecs = require("Jecs")
local TimeUtil = require("TimeUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local VelocitySystem = {}

-- [ Types ] --
type ModuleData = {
    _World: Jecs.World,
    _Tags: EntityTypesClient.Tags,
    _Components: EntityTypesClient.Components,
    _Signals: EntityTypesClient.PublicSignals,
    _ActiveInstances: {
        [Jecs.Entity]: {
            Velocity: LinearVelocity,
            Attachment: Attachment,
        }
    }
}

export type Module = typeof(VelocitySystem) & ModuleData

-- [ Private Functions ] --
function VelocitySystem._HandleLinearVelocity(self: Module, humnaoidRootPart: BasePart, velocity: EntityTypesClient.VelocityComponent)

end

-- [ Public Functions ] --
function VelocitySystem.Update(self: Module, dt: number)
    local World = self._World
    local Components = self._Components

    for entity, character: EntityTypesClient.CharacterComponent, velocity: EntityTypesClient.VelocityComponent in World:query(Components.Character, Components.Velocity) do
        local Elapsed = TimeUtil:GetTime() - velocity.StartTime

        local _Alpha = math.clamp(Elapsed/velocity.Duration,0,1)
        local SpeedMul = 1

        if velocity.Mode == "Plane" then
            if velocity.Curve == "Linear" then
                SpeedMul = 1
            end

            velocity.Instance.PlaneVelocity = velocity.GetDirection() * (velocity.StartSpeed * SpeedMul)
        end

        if velocity.StartTime + velocity.Duration < TimeUtil:GetTime() then
            velocity.Attachment0:Destroy()
            velocity.Instance:Destroy()

            World:remove(entity, Components.Velocity)
        end
    end
end

function VelocitySystem.Init(self: Module, context: EntityTypesClient.SystemModule_Init_Context)
    self._World = context.World
    self._Tags = context.Tags
    self._Components = context.Components
    self._Signals = context.Signals
    self._ActiveInstances = {}
end

return VelocitySystem :: Module
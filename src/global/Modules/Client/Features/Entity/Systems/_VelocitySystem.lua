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

VelocitySystem._ActiveInstances = {} :: {
    [Jecs.Entity]: {
        Velocity: LinearVelocity,
        Attachment: Attachment,
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(VelocitySystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function VelocitySystem.Update(self: Module, context: EntityTypesClient.SystemModuleUpdateContext)
    local World = context.World
    local Components = context.Components

    for entity, character: EntityTypesClient.CharacterComponent, velocity: EntityTypesClient.VelocityComponent in World:query(Components.Character, Components.Velocity) do
        local HumanoidRootPart = character.Character:FindFirstChild("HumanoidRootPart")

        if not HumanoidRootPart then
            return
        end

        local ActiveInstances = self._ActiveInstances[entity]

        if not ActiveInstances then
            local Attachment = Instance.new("Attachment") :: Attachment
            Attachment.Parent = HumanoidRootPart

            local Velocity = Instance.new(velocity.VelocityType) :: LinearVelocity
            Velocity.VelocityConstraintMode = velocity.Mode
            Velocity.PlaneVelocity = velocity.PlaneVelocity * velocity.StartSpeed
            Velocity.PrimaryTangentAxis = velocity.PrimaryTangentAxis
            Velocity.SecondaryTangentAxis = velocity.SecondaryTangentAxis
            Velocity.Attachment0 = Attachment
            Velocity.Parent = HumanoidRootPart
            Velocity.MaxForce = math.huge

            self._ActiveInstances[entity] = {
                Velocity = Velocity,
                Attachment = Attachment
            }
        end

        if velocity.StartTime + velocity.Duration < TimeUtil:GetTime() then
            self._ActiveInstances[entity].Attachment:Destroy()
            self._ActiveInstances[entity].Velocity:Destroy()
            self._ActiveInstances[entity] = nil

            World:remove(entity, Components.Velocity)
        end
    end
end

return VelocitySystem :: Module
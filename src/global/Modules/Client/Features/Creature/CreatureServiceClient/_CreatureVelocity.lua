--[=[
    @class CreatureGeneric
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local VelocityUtil = require("VelocityUtil")
local Jecs = require("Jecs")
local CreatureTypesClient = require("CreatureTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureGeneric = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))
type ModuleData = {
    _EntityServiceClient: EntityServiceClient
}

export type Module = typeof(CreatureGeneric) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureGeneric.ApplyLinearVelocityOnCreature(self: Module, entity: Jecs.Entity, componentConfig: CreatureTypesClient.ComponentConfig, velocityConfig: CreatureTypesClient.LinearVelocityConfig)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local Character = World:get(entity, Components.Character)

    if not Character then
        return
    end

    local HumanoidRootPart = Character.Character:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not HumanoidRootPart then
        return
    end
    
    if velocityConfig.Mode == "Plane" then
        local Attachment = VelocityUtil:CreateAttachment(HumanoidRootPart)
        local LinearVelocity = VelocityUtil:CreateLinearVelocity(HumanoidRootPart, {
            Mode = velocityConfig.Mode,
            Attachment0 = Attachment,
            ForceLimitMode = velocityConfig.ForceLimitMode,
            MaxForce = velocityConfig.MaxForce,
            ForceLimitsEnabled = velocityConfig.ForceLimitsEnabled,
            RelativeTo = velocityConfig.RelativeTo,
            PlaneVelocity = velocityConfig.PlaneVelocity,
            PrimaryTangentAxis = velocityConfig.PrimaryTangentAxis,
            SecondaryTangentAxis = velocityConfig.SecondaryTangentAxis,
        })

        World:set(entity, Components.Velocity, {
            Mode = componentConfig.Mode,
            Instance = LinearVelocity,
            Attachment0 = Attachment,
            StartTime = componentConfig.StartTime,
            StartSpeed = componentConfig.StartSpeed,
            Duration = componentConfig.Duration,
            GetDirection = componentConfig.GetDirection,
            Curve = componentConfig.Curve,
        })
    end
end

function CreatureGeneric.Init(self: Module, context: CreatureTypesClient.Init_Context)
    self._EntityServiceClient = context.EntityServiceClient
end

function CreatureGeneric.Start(self: Module)
    
end

return CreatureGeneric :: Module
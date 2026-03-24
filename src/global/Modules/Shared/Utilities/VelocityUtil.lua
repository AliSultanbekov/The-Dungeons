--[=[
    @class VelocityUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local VelocityUtil = {}

-- [ Types ] --
export type LinearVelocityConfig = {
    Mode: "Line",

} | {
    Mode: "Plane",
    Attachment0: Attachment,
    ForceLimitMode: Enum.ForceLimitMode,
    MaxForce: number,
    ForceLimitsEnabled: boolean,
    RelativeTo: Enum.ActuatorRelativeTo,
    PlaneVelocity: Vector2,
    PrimaryTangentAxis: Vector3,
    SecondaryTangentAxis: Vector3,
} | {
    Mode: "Vector",

}


type ModuleData = {}

export type Module = typeof(VelocityUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function VelocityUtil.CreateAttachment(self: Module, parent: BasePart): Attachment
    local Attachment = Instance.new("Attachment")
    Attachment.Name = "VelocityAttachment"
    Attachment.Parent = parent

    return Attachment
end

function VelocityUtil.CreateLinearVelocity(self: Module, parent: BasePart, config: LinearVelocityConfig)
    if config.Mode == "Plane" then
        local LinearVelocity = Instance.new("LinearVelocity")
        LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
        LinearVelocity.Attachment0 = config.Attachment0
        LinearVelocity.ForceLimitMode = config.ForceLimitMode
        LinearVelocity.MaxForce = config.MaxForce
        LinearVelocity.ForceLimitMode = config.ForceLimitMode
        LinearVelocity.RelativeTo = config.RelativeTo
        LinearVelocity.PlaneVelocity = config.PlaneVelocity
        LinearVelocity.PrimaryTangentAxis = config.PrimaryTangentAxis
        LinearVelocity.SecondaryTangentAxis = config.SecondaryTangentAxis
        LinearVelocity.Parent = parent
        return LinearVelocity
    end

    error(`Invalid LinearVelocity Mode: {config.Mode}`)
end

return VelocityUtil :: Module
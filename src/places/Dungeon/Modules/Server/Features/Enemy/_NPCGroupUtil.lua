--[=[
    @class NPCGroupUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("./_Types")

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NPCGroupUtil = {}

-- [ Types ] --
type Member = Types.Member
export type Module = typeof(NPCGroupUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function NPCGroupUtil.GetFlatVector(self: Module, v: Vector3): Vector3
    return Vector3.new(v.X, 0, v.Z)
end

function NPCGroupUtil.GetFlatDistance(self: Module, a: Vector3, b: Vector3): number
    return (Vector3.new(b.X, 0, b.Z) - Vector3.new(a.X, 0, a.Z)).Magnitude
end

function NPCGroupUtil.GetNoiseOffset(self: Module, seed: number, time: number, freq: number, amp: number): Vector3
	local XNoise = math.noise(time * freq, seed)
	local ZNoise = math.noise(time * freq, seed + 13.5)
	return Vector3.new(XNoise, 0, ZNoise) * amp
end

function NPCGroupUtil.RaycastToFloor(pos: Vector3, ignoreList: { Instance }): Vector3
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = ignoreList
    Params.FilterType = Enum.RaycastFilterType.Exclude

    local Result = workspace:Raycast(pos + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), Params)
    return Result and Result.Position or pos
end

function NPCGroupUtil.CreateMember(self: Module, x: number, y: number, isLeader: boolean, id: number, config: Types.Config, template: Model, folder: Instance): Member
    local Clone = template:Clone()
    Clone.Parent = folder
    Clone.Name = isLeader and "SquadLeader" or string.format("Trooper_%d", id)

    local Hum = Clone:WaitForChild("Humanoid") :: Humanoid
    local Root = Clone:WaitForChild("HumanoidRootPart") :: BasePart

    local Head = Clone:WaitForChild("Head") :: BasePart
    local Neck = Head:FindFirstChild("Neck") :: BasePart?

    Hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

    local OffsetX = (x - (config.SquadSizeX + 1) / 2) * config.Spacing
    local OffsetZ = 0

    if not isLeader then
		OffsetZ = config.LeaderGap + ((y - 1) * config.Spacing)
	end

    return {
        Model = Clone,
		Humanoid = Hum,
		RootPart = Root,
		Neck = Neck,
		ID = id,
		GridX = x,
		GridY = y,
		Offset = Vector3.new(OffsetX, 0, OffsetZ),
		IsLeader = isLeader,
		Seed = math.random() * 1000, -- Random seed for noise
		LastPos = Root.Position,
		TargetPos = Root.Position,
		CurrentSpeed = config.BaseSpeed,
		IsScanning = false,
    }
end

return NPCGroupUtil :: Module
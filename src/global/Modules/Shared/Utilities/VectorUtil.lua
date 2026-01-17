--[=[
    @class VectorUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local VectorUtil = {}

-- [ Types ] --
export type Module = typeof(VectorUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function VectorUtil.CheckOBBIntersection(
    self: Module,
    cframe1: CFrame,
    size1: Vector3,
    cframe2: CFrame,
    size2: Vector3,
    tolerance: number?
): boolean
    local Tolerance = tolerance or 0
    
    local HalfSize1 = (size1 + Vector3.new(Tolerance, Tolerance, Tolerance)) / 2
    local HalfSize2 = (size2 + Vector3.new(Tolerance, Tolerance, Tolerance)) / 2
    
    local RelativeCFrame = cframe1:ToObjectSpace(cframe2)
    local RelativePos = RelativeCFrame.Position
    
    local Axes = {
        RelativeCFrame.RightVector,
        RelativeCFrame.UpVector,
        RelativeCFrame.LookVector
    }
    
    local Extents2 = Vector3.new(
        math.abs(Axes[1].X * HalfSize2.X) + math.abs(Axes[2].X * HalfSize2.Y) + math.abs(Axes[3].X * HalfSize2.Z),
        math.abs(Axes[1].Y * HalfSize2.X) + math.abs(Axes[2].Y * HalfSize2.Y) + math.abs(Axes[3].Y * HalfSize2.Z),
        math.abs(Axes[1].Z * HalfSize2.X) + math.abs(Axes[2].Z * HalfSize2.Y) + math.abs(Axes[3].Z * HalfSize2.Z)
    )
    
    local testX = math.abs(RelativePos.X) <= HalfSize1.X + Extents2.X
    local testY = math.abs(RelativePos.Y) <= HalfSize1.Y + Extents2.Y
    local testZ = math.abs(RelativePos.Z) <= HalfSize1.Z + Extents2.Z
    
    return testX and testY and testZ
end

return VectorUtil :: Module
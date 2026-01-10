--[=[
    @class HitboxClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HitboxClass = {}
HitboxClass.__index = HitboxClass

-- [ Types ] --
export type Cb = (hitCharacter: Model) -> ()
export type SphereParams = {
    HitboxClassType: "Sphere",
    CFrame: CFrame,
    Radius: number,
    Cb: Cb,
    RelativeTo: CFrame?,
    Ignore: { any }?,
    Visualise: boolean?,
}
export type BoxParams = {
    HitboxClassType: "Box",
    CFrame: CFrame,
    Size: Vector3,
    Cb: Cb,
    RelativeTo: CFrame?,
    Ignore: { any }?,
    Visualise: boolean?,
}
export type Params = SphereParams | BoxParams
export type ObjectData = {
    Trigger: (self: Object) -> (),
}
export type Object = ObjectData & {
    _Params: Params,
    _Cb: Cb,
}
export type Module = {
    __index: Module,
    new: (params: Params) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function HitboxClass.new(params: Params): Object
    local self = setmetatable({} :: any, HitboxClass) :: Object

    self._Params = params

    return self
end

function HitboxClass.Trigger(self: Object)
    local Overlap = OverlapParams.new()
    Overlap.FilterDescendantsInstances = self._Params.Ignore or {}
    Overlap.RespectCanCollide = false

    local Params = self._Params
    local Parts = nil
    local FinalCFrame = Params.CFrame * (Params.RelativeTo or CFrame.new())

    if Params.HitboxClassType == "Box" then
        if Params.Visualise then
            local Visual = Instance.new("Part")
            Visual.Name = "VisualBaba"
            Visual.Parent = workspace.World.Effects
            Visual.Size = Params.Size
            Visual.Anchored = true
            Visual.CanCollide = false
            Visual.Transparency = 0.9
            Visual.Color = Color3.new(1, 0, 0)
            Visual:PivotTo(FinalCFrame)

            task.delay(1, function()
                Visual:Destroy()
            end)
        end

        Parts = workspace:GetPartBoundsInBox(FinalCFrame, Params.Size, Overlap)
    elseif Params.HitboxClassType == "Sphere" then
        if Params.Visualise then
            local Visual = Instance.new("Part")
            Visual.Shape = Enum.PartType.Ball
            Visual.Name = "VisualBaba"
            Visual.Parent = workspace.World.Effects
            Visual.Size = Vector3.new(Params.Radius, Params.Radius, Params.Radius)
            Visual.Anchored = true
            Visual.CanCollide = false
            Visual.Transparency = 0.9
            Visual.Color = Color3.new(1, 0, 0)
            Visual:PivotTo(FinalCFrame)

            task.delay(1, function()
                Visual:Destroy()
            end)
        end

        Parts = workspace:GetPartBoundsInRadius(FinalCFrame, Params.Radius, Overlap)
    end

    if not Parts then
        return
    end

    local Seen = {}
    local Hits = {}

    for _, instance in Parts do
        local Model = instance:FindFirstAncestorOfClass("Model")

        if not Model then
            continue
        end

        if Seen[Model] then
            continue
        end

        Seen[Model] = true

        local Humanoid = Model:FindFirstChildOfClass("Humanoid")

        if not Humanoid then
            continue
        end

        if Humanoid.Health <= 0 then
            continue
        end

        table.insert(Hits, Model)
    end

    for _, character in Hits do
        Params.Cb(character)
    end
end

return HitboxClass :: Module
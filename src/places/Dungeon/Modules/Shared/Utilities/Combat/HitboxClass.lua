local RunService = game:GetService("RunService")
--[=[
    @class HitboxClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HitboxClass = {}
HitboxClass.__index = HitboxClass

-- [ Types ] --
type Seen = { [Model]: boolean }
type Hits = { Model }
export type Cb = (hitCharacter: Model) -> ()
export type SphereParams = {
    HitboxType: "Sphere",
    GetCFrame: () -> CFrame,
    Radius: number,
    Length: number?,
    Cb: Cb?,
    Ignore: { any }?,
    Visualise: boolean?,
}
export type BoxParams = {
    HitboxType: "Box",
    GetCFrame: () -> CFrame,
    Size: Vector3,
    Length: number?,
    Cb: Cb?,
    Ignore: { any }?,
    Visualise: boolean?,
}
export type Params = SphereParams | BoxParams
export type ObjectData = {
    _Maid: Maid.Maid,
    _Params: Params,
}
export type Object = ObjectData & {
    _CheckHitbox: (self: Object, seen: Seen, hits: Hits) -> (),
    Trigger: (self: Object) -> Hits,
}
export type Module = {
    __index: Module,
    new: (params: Params) -> Object
}

-- [ Private Functions ] --
function HitboxClass._CheckHitbox(self: Object, seen: Seen, hits: Hits)
    local Overlap = OverlapParams.new()
    Overlap.FilterDescendantsInstances = self._Params.Ignore or {}
    Overlap.RespectCanCollide = false

    local Params = self._Params
    local Parts = nil
    local FinalCFrame = (Params :: any).GetCFrame()

    if Params.HitboxType == "Box" then
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

            task.delay(0.2, function()
                Visual:Destroy()
            end)
        end

        Parts = workspace:GetPartBoundsInBox(FinalCFrame, Params.Size, Overlap)
    elseif Params.HitboxType == "Sphere" then
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

            task.delay(0.2, function()
                Visual:Destroy()
            end)
        end

        Parts = workspace:GetPartBoundsInRadius(FinalCFrame, Params.Radius, Overlap)
    end

    if not Parts then
        return
    end

    for _, instance in Parts do
        local Model = instance:FindFirstAncestorOfClass("Model")

        if not Model then
            continue
        end

        if seen[Model] then
            continue
        end

        seen[Model] = true

        local Humanoid = Model:FindFirstChildOfClass("Humanoid")

        if not Humanoid then
            continue
        end

        if Humanoid.Health <= 0 then
            continue
        end     

        table.insert(hits, Model)
        
        if Params.Cb then
            Params.Cb(Model)
        end
    end
end

-- [ Public Functions ] --
function HitboxClass.new(params: Params): Object
    local self = setmetatable({} :: any, HitboxClass) :: Object

    self._Maid = Maid.new()
    self._Params = params

    return self
end

function HitboxClass:Trigger(): Hits
    local Params = self._Params
    local Length = Params.Length or 0
    local Seen = {}
    local Hits = {}
    
    if Length > 0 then
        local Event = RunService:IsClient() and RunService.RenderStepped or RunService.Heartbeat
        local Elapsed = 0
        
        self._Maid:Add(Event:Connect(function(dt)
            Elapsed += dt
            self:_CheckHitbox(Seen, Hits)
            
            if Elapsed >= Length then
                self._Maid:DoCleaning()
            end
        end))
        
        task.wait(Length)
    else
        self:_CheckHitbox(Seen, Hits)
    end
    
    return Hits
end

return HitboxClass :: Module
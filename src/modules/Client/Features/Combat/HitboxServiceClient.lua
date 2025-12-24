--[=[
    @class HitboxServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HitboxServiceClient = {}

-- [ Types ] --
type SphereParams = {
    HitboxType: "Sphere",
    Position: Vector3?,
    CFrame: CFrame?,
    Radius: number,
    Ignore: { Instance }?,
    Duration: number?,
    Cb: (character: Model) -> (),
    Visualise: boolean?,
}

type BoxParams = {
    HitboxType: "Box",
    Position: Vector3?,
    CFrame: CFrame?,
    Size: Vector3,
    Ignore: { Instance }?,
    Duration: number?,
    Cb: (character: Model) -> (),
    Visualise: boolean?,
}

type Params = BoxParams | SphereParams

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(HitboxServiceClient) & ModuleData

-- [ Private Functions ] --
function HandleCb(parts: { BasePart }, cb: (character: Model) -> ())
    local Seen = {}
    local Hits = {}

    for _, instance in parts do
        local Model: Model? = instance:FindFirstAncestorOfClass("Model")

        if not Model then
            continue
        end

        if Seen[Model] then
            continue
        end

        Seen[Model] = true

        local Humanoid: Humanoid? = Model:FindFirstChildOfClass("Humanoid")

        if not Humanoid then
            continue
        end

        if Humanoid.Health <= 0 then
            continue
        end

        table.insert(Hits, Model)
    end

    for _, character in Hits do
        cb(character)
    end
end

-- [ Public Functions ] --  
function HitboxServiceClient.Create(self: Module, params: Params)
    local Overlap = OverlapParams.new()
    Overlap.FilterType = Enum.RaycastFilterType.Exclude
    Overlap.FilterDescendantsInstances = params.Ignore or {}
    Overlap.RespectCanCollide = false

    local Cb = params.Cb
    local Parts = nil
    local Visualise = params.Visualise or false

    if params.HitboxType == "Box" then
        local CFrame = params.Position and CFrame.new(params.Position or Vector3.new(0, 0, 0)) or params.CFrame :: CFrame
        local Size = params.Size

        if Visualise then
            local Visual = Instance.new("Part")
            Visual.Size =  Size
            Visual.CFrame = CFrame
            Visual.CanCollide = false
            Visual.Anchored = true
            Visual.Color = Color3.new(1, 0, 0)
            Visual.Transparency = 0.7
            Visual.Parent = workspace

            task.delay(1, function()
                Visual:Destroy()
            end)
        end

        Parts = workspace:GetPartBoundsInBox(CFrame, Size, Overlap)
    elseif params.HitboxType == "Sphere" then
        local Position = params.Position or params.CFrame and params.CFrame.Position
        local Radius = params.Radius

        if not Position then
            return
        end

        if Visualise then
            local Visual = Instance.new("Part")
            Visual.Shape = Enum.PartType.Ball
            Visual.Size =  Vector3.new(Radius*2, Radius*2, Radius*2)
            Visual.Position = Position
            Visual.CanCollide = false
            Visual.Anchored = true
            Visual.Color = Color3.new(1, 0, 0)
            Visual.Transparency = 0.7
            Visual.Parent = workspace

            task.delay(1, function()
                Visual:Destroy()
            end)
        end

        Parts = workspace:GetPartBoundsInRadius(Position, Radius, Overlap)
    end

    print()

    if not Parts then
        return
    end

    HandleCb(Parts, Cb)
end

function HitboxServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function HitboxServiceClient.Start(self: Module)
    
end

return HitboxServiceClient :: Module
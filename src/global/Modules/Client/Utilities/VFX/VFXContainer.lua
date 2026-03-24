--[=[
    @class VFXContainer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local VFXContainer = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(VFXContainer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function VFXContainer.FromAttachment(self: Module, parent: Instance, cframe: CFrame): Attachment
    local Instance = Instance.new("Attachment")
    Instance.Name = "VFXAttachment"
    Instance.Parent = parent
    Instance.CFrame = cframe

    return Instance
end

function VFXContainer.FromShape(self: Module, shape: Enum.PartType, size: Vector3, cframe: CFrame): Part
    local Instance = Instance.new("Part")
    Instance.Shape = shape
    Instance.Name = "VFXAttachment"
    Instance.Parent = workspace.World.Effects
    Instance.CFrame = cframe
    Instance.Size = size

    return Instance
end

return VFXContainer :: Module
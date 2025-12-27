--[=[
    @class CameraController
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
local CameraController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(CameraController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CameraController.SetCamPosition(self: Module, position: Vector3)
    local Cam = self:GetCam()

    Cam:PivotTo(CFrame.new(position))
end

function CameraController.GetCam(self: Module): Camera
    return workspace.CurrentCamera
end

function CameraController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function CameraController.Start(self: Module)
    
end

return CameraController :: Module
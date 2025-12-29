--[=[
    @class CameraController
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local rbxrequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --
local PresetsFolder = script.Parent.Presets

-- [ Module Table ] --
local CameraController = {}

-- [ Types ] --
type PresetModule = {
    Start: (self: any, cameraController: Module) -> (),
}

type Update = (dt: number) -> ()

type State = "Ready" | "Busy" | string

type Preset = "Reset" | "InventoryEquipment"

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _OwnsTheCamera: boolean,
    _State: State,
    _Update: Update?,
    _Presets: { [string]: PresetModule },
    _CurrentPreset: Preset?,
    _SavePoint: CFrame
}

export type Module = typeof(CameraController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CameraController.RunPreset(self: Module, presetName: Preset)
    if self._State == "Busy" then
        return
    end

    self:ForcePreset(presetName)
end

function CameraController.ForcePreset(self: Module, presetName: Preset)
    self:TerminatePreset()

    self._State = "Busy"
    self._CurrentPreset = presetName

    local Preset = self._Presets[presetName]

    Preset:Start(self)
end

function CameraController.TerminatePreset(self: Module)
    self:ClearUpdate()
    self:ReleaseOwnership()
    self._CurrentPreset = nil
    self._State = "Ready"
end

function CameraController.GetCurrentPreset(self: Module): Preset?
    return self._CurrentPreset
end

function CameraController.SetUpdate(self: Module, update: Update)
    self._Update = update
end

function CameraController.ClearUpdate(self: Module)
    self._Update = nil
end

function CameraController.GetState(self: Module): State
    return self._State
end

function CameraController.SetState(self: Module, state: State)
    self._State = state
end

function CameraController.GetSavePoint(self: Module)
    return self._SavePoint
end

function CameraController.CaptureSavePoint(self: Module)
    self._SavePoint = self:GetCamera():GetPivot()
end

function CameraController.TakeOwnership(self: Module)
    if self._OwnsTheCamera == true then
        return
    end

    self._OwnsTheCamera = true

    self:GetCamera().CameraType = Enum.CameraType.Scriptable
end

function CameraController.ReleaseOwnership(self: Module)
    if self._OwnsTheCamera == false then
        return
    end

    self._OwnsTheCamera = false

    self:GetCamera().CameraType = Enum.CameraType.Custom
end

function CameraController.GetCamera(self: Module): Camera
    return workspace.CurrentCamera
end

function CameraController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._OwnsTheCamera = false
    self._State = "Ready"
    self._Update = nil
    self._Presets = {}
    self._CurrentPreset = nil
    self._SavePoint = CFrame.new()

    for _, inst in PresetsFolder:GetChildren() do
        if not inst:IsA("ModuleScript") or inst.Name == "loader" then
            continue
        end
        local parts = inst.Name:split("_")
        local name = parts[#parts]
        self._Presets[name] = rbxrequire(inst) :: PresetModule
    end
end

function CameraController.Start(self: Module)
    RunService:BindToRenderStep("CameraController", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
        if self._Update then
            self._Update(dt)
        end
    end)
end

return CameraController :: Module
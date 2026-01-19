--[=[
    @class CameraManager
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
local CameraManager = {}

-- [ Types ] --
type PresetModule = {
    Start: (self: any, CameraManager: Module) -> (),
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
    _SavePoint: CFrame,
    _RelativeSavePoint: CFrame,
}

export type Module = typeof(CameraManager) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CameraManager.RunPreset(self: Module, presetName: Preset)
    if self._State == "Busy" then
        return
    end

    self:ForcePreset(presetName)
end

function CameraManager.ForcePreset(self: Module, presetName: Preset)
    self:TerminatePreset()

    self._State = "Busy"
    self._CurrentPreset = presetName

    local Preset = self._Presets[presetName]

    Preset:Start(self)
end

function CameraManager.TerminatePreset(self: Module)
    self:ClearUpdate()
    self:ReleaseOwnership()
    self._CurrentPreset = nil
    self._State = "Ready"
end

function CameraManager.GetCurrentPreset(self: Module): Preset?
    return self._CurrentPreset
end

function CameraManager.SetUpdate(self: Module, update: Update)
    self._Update = update
end

function CameraManager.ClearUpdate(self: Module)
    self._Update = nil
end

function CameraManager.GetState(self: Module): State
    return self._State
end

function CameraManager.SetState(self: Module, state: State)
    self._State = state
end

function CameraManager.GetRelativeSavePoint(self: Module)
    return self._RelativeSavePoint
end

function CameraManager.CaptureRelativeSavePoint(self: Module, instance: BasePart)
    self._RelativeSavePoint = instance:GetPivot():ToObjectSpace(self:GetCamera():GetPivot())
end

function CameraManager.GetSavePoint(self: Module)
    return self._SavePoint
end

function CameraManager.CaptureSavePoint(self: Module)
    self._SavePoint = self:GetCamera():GetPivot()
end

function CameraManager.TakeOwnership(self: Module)
    if self._OwnsTheCamera == true then
        return
    end

    self._OwnsTheCamera = true

    self:GetCamera().CameraType = Enum.CameraType.Scriptable
end

function CameraManager.ReleaseOwnership(self: Module)
    if self._OwnsTheCamera == false then
        return
    end

    self._OwnsTheCamera = false

    self:GetCamera().CameraType = Enum.CameraType.Custom
end

function CameraManager.GetCamera(self: Module): Camera
    return workspace.CurrentCamera
end

function CameraManager.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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
    self._RelativeSavePoint = CFrame.new()

    for _, inst in PresetsFolder:GetChildren() do
        if not inst:IsA("ModuleScript") or inst.Name == "loader" then
            continue
        end
        local parts = inst.Name:split("_")
        local name = parts[#parts]
        self._Presets[name] = rbxrequire(inst) :: PresetModule
    end
end

function CameraManager.Start(self: Module)
    RunService:BindToRenderStep("CameraManager", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
        if self._Update then
            self._Update(dt)
        end
    end)
end

return CameraManager :: Module
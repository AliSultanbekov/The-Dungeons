--[=[
    @class EquipmentDisplayClass
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] -- 
local AssetProvider = require("AssetProvider")
local GetPartFromCharacter = require("GetPartFromCharacter")
local Easings = require("Easings")

-- [ Constants ] --
local FINAL_SIZE = Vector3.new(6,5,0.01)
local START_SIZE = Vector3.new(6,0.01,0.01)

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local EquipmentDisplayClass = {}
EquipmentDisplayClass.__index = EquipmentDisplayClass

-- [ Types ] --
type EquipmentDisplayUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.EquipmentDisplayUI)

type Update = (dt: number) -> ()

export type ObjectData = {
    _UI: EquipmentDisplayUI,
    _AdorneePart: BasePart,
    _Update: Update?,
}
export type Object = ObjectData & Module
export type Module = typeof(EquipmentDisplayClass)

-- [ Private Functions ] --
function EquipmentDisplayClass._CreateUI(self: Object): EquipmentDisplayUI
    local UI = AssetProvider:Get("UIs/Inventory/EquipmentDisplayUI") :: EquipmentDisplayUI
    UI.Parent = Player.PlayerGui.Misc
    UI.Adornee = nil

    return UI
end

function EquipmentDisplayClass._CreatePart(self: Object): BasePart
    local Part = Instance.new("Part")
    Part.Parent = nil
    Part.Transparency = 1
    Part.Size = START_SIZE
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanQuery = false
    Part.CanTouch = false

    return Part
end

function EquipmentDisplayClass._ClearUpdate(self: Object)
    self._Update = nil
end

function EquipmentDisplayClass._SetUpdate(self: Object, update: Update)
    self._Update = update
end

function Lerp(a: number, b: number, alpha: number)
    return a + (b - a) * alpha
end

-- [ Public Functions ] --
function EquipmentDisplayClass.new(): Object
    local self = setmetatable({} :: any, EquipmentDisplayClass) :: Object

    self._UI = self:_CreateUI()
    self._AdorneePart = self:_CreatePart()
    self._Update = nil

    RunService.RenderStepped:Connect(function(dt: number)
        self:OnRenderStepped(dt)
    end)

    return self
end

function EquipmentDisplayClass.Show(self: Object)
    self:_ClearUpdate()

    self._AdorneePart.Parent = workspace.World.Effects
    self._UI.Adornee = self._AdorneePart

    local Duration = 1
    local Elapsed = 0

    local Size = self._AdorneePart.Size

    self:_SetUpdate(function(dt: number)
        local HumanoidRootPart = GetPartFromCharacter:GetPart(Player, "HumanoidRootPart")

        if not HumanoidRootPart then
            return
        end
        
        Elapsed += dt

        local Alpha = math.clamp(Elapsed/Duration, 0, 1)
        local EasedAlpha = Easings:OutQuint(Alpha)

        local XLerp = Lerp(Size.X, FINAL_SIZE.X, EasedAlpha)
        local YLerp = Lerp(Size.Y, FINAL_SIZE.Y, EasedAlpha)
        local ZLerp = Lerp(Size.Z, FINAL_SIZE.Z, EasedAlpha)

        self._AdorneePart.Size = Vector3.new(XLerp, YLerp, ZLerp)
        self._AdorneePart:PivotTo(HumanoidRootPart:GetPivot() * CFrame.new(0, 2, -1) * CFrame.new(0, -YLerp/2, 0))

        if Alpha >= 1 then
            self:_ClearUpdate()
        end
    end)
end

function EquipmentDisplayClass.Hide(self: Object)
    self:_ClearUpdate()

    local Duration = 1
    local Elapsed = 0

    local Size = self._AdorneePart.Size

    self:_SetUpdate(function(dt: number)
        local HumanoidRootPart = GetPartFromCharacter:GetPart(Player, "HumanoidRootPart")

        if not HumanoidRootPart then
            return
        end
        

        Elapsed += dt

        local Alpha = math.clamp(Elapsed/Duration, 0, 1)
        local EasedAlpha = Easings:OutQuint(Alpha)

        local XLerp = Lerp(Size.X, START_SIZE.X, EasedAlpha)
        local YLerp = Lerp(Size.Y, START_SIZE.Y, EasedAlpha)
        local ZLerp = Lerp(Size.Z, START_SIZE.Z, EasedAlpha)

        self._AdorneePart.Size = Vector3.new(XLerp, YLerp, ZLerp)
        self._AdorneePart:PivotTo(HumanoidRootPart:GetPivot() * CFrame.new(0, 2, -1) * CFrame.new(0, -YLerp/2, 0))

        if Alpha >= 1 then
            self._AdorneePart.Parent = nil
            self._UI.Adornee = nil
            self:_ClearUpdate()
        end
    end)
end

function EquipmentDisplayClass.OnRenderStepped(self: Object, dt: number)
    if not self._Update then
        return
    end

    self._Update(dt)
end

return EquipmentDisplayClass :: Module
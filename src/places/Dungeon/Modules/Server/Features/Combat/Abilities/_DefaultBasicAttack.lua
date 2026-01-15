local Players = game:GetService("Players")
--[=[
    @class DefaultBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local ItemTypes = require("ItemTypes")
local WeaponConfig = require("WeaponConfig")
local Table = require("Table")
local CombatConfig = require("CombatConfig")

-- [ Constants ] --
local BASE_ANGLE = math.rad(90)
local ANGLE_PER_100MS = math.rad(30)
local PROCESSING_DELAY = 0.07

-- [ Variables ] --

-- [ Module Table ] --
local DefaultBasicAttack = {
    AbilityName = "DefaultBasicAttack"
}
DefaultBasicAttack.__index = DefaultBasicAttack

-- [ Types ] --
type PositionHistoryService = typeof(require("PositionHistoryService"))
type Config = {
    AbilityName: string,
    MaxDelay: number,
    Combo: { 
        [number]: {
            Animation: string,
            Damage: number,
            Range: Vector3,
            Angle: number,
            Time: number
        }
    }
}
type WeaponItemData = ItemTypes.WeaponItemData
type ValidateHit_Params = {
    Attacker: Model,
    Attacked: Model,
    AttackerCFrame: CFrame?,
}
type Use_Params = {
    ItemData: WeaponItemData
}
type Apply_Params = {
    Mode: "FromServer",
    Attacker: Model,
    Attacked: Model,
} | {
    Mode: "FromClient",
    Attacker: Model,
    Attacked: Model,
    AttackerCFrame: CFrame,
}

type New_Params = {
    ItemData: WeaponItemData,
    PositionHistoryService: PositionHistoryService,
}
export type ObjectData = {
    _WeaponData: WeaponItemData,
    _PositionHistoryService: PositionHistoryService,
    _Config: Config,
    _ActiveUntil: number,
    _FirstHitTime: number?,
    _Combo: number,
}
export type ModuleData = {
    AbilityName: string,
}
export type Object = ModuleData & ObjectData & {
    _GetDelta: (self: Object, attacker: Model, attacked: Model) -> Vector3,
    _ValidateHit: (self: Object, params: Apply_Params) -> (),
    _ValidatePosition: (self: Object, attacker: Model, position: Vector3) -> boolean,
    _IncrementCombo: (self: Object) -> (),
    _ResetCombo: (self: Object) -> (),
    _SetupCombo: (self: Object, cb: (comboNumber: number) -> ()) -> (),
    _IsActive: (self: Object) -> boolean,
}
export type Module = ModuleData & {
    __index: Module,
    new: (params: New_Params) -> Object
}

-- [ Private Functions ] --
function DefaultBasicAttack._ValidateHit(self: Object, params: Apply_Params)
    local Config = self._Config
    local Combo = self._Combo
    local CurrentComboData = Config.Combo[Combo]

    local Attacker = params.Attacker
    local Attacked = params.Attacked

    local AttackerHitbox = Attacker:FindFirstChild("Hitbox") :: BasePart?
    local AttackedHitbox = Attacked:FindFirstChild("Hitbox") :: BasePart?

    if not AttackerHitbox or not AttackedHitbox then
        return false
    end

    local function validate(attackedPosition: Vector3, AttackerCFrame: CFrame): boolean
        local Delta = attackedPosition - AttackerCFrame.Position
        local Distance = Delta.Magnitude
        local Direction = Delta.Unit

        local FlatDirection = Vector3.new(Direction.X, 0, Direction.Z).Unit
        local AttackedRadius = (AttackedHitbox.Size.X + AttackedHitbox.Size.Z)/2
        local Look = AttackerCFrame.LookVector
        local FlatLook = Vector3.new(Look.X, 0, Look.Z).Unit

        if FlatLook.Magnitude < 1e-6 then
            return false
        end

        if CurrentComboData.Range.Z + AttackedRadius + CombatConfig.DistanceTolerance < Distance then
            return false
        end

        local Dot = FlatLook:Dot(FlatDirection)

        if Dot < -0.5 then
            return false
        end

        if CurrentComboData.Angle - CombatConfig.AngleTolerance > Dot then
            return false
        end

        return true
    end

    if params.Mode == "FromClient" then
        local Player = Players:GetPlayerFromCharacter(Attacker)

        if not Player then
            return false
        end

        local Ping = PROCESSING_DELAY + Player:GetNetworkPing()
        local MaxReasonableMovement = 50 * Ping
        local MaxReasonableAngle = BASE_ANGLE + (ANGLE_PER_100MS * (Ping / 0.1))

        local AttackerCFrame = params.AttackerCFrame

        local ServerLook = Attacker:GetPivot().LookVector
        local ClientLook = AttackerCFrame.LookVector
        local RotationDiff = math.acos(math.clamp(ClientLook:Dot(ServerLook), -1, 1))

        if RotationDiff > MaxReasonableAngle then
            return false
        end

        local ServerPosition = Attacker:GetPivot().Position
        local ClientPositon = AttackerCFrame.Position
        local PositionDiff = (ClientPositon - ServerPosition).Magnitude

        if MaxReasonableMovement < PositionDiff then
            return false
        end

        local RewoundAttackedPosition = self._PositionHistoryService:GetPosition(Attacked, os.clock() - Ping)

        return validate(RewoundAttackedPosition or Attacked:GetPivot().Position, AttackerCFrame)
    elseif params.Mode == "FromServer" then
        return validate(Attacked:GetPivot().Position, Attacker:GetPivot())
    end

    return false
end

function DefaultBasicAttack._IncrementCombo(self: Object)
    if self._Combo == 0 then
        self._FirstHitTime = os.clock()
    end

    self._Combo += 1
end

function DefaultBasicAttack._ResetCombo(self: Object)
    self._Combo = 0
    self._FirstHitTime = nil
end

function DefaultBasicAttack._SetupCombo(self: Object, cb: (comboNumber: number) -> ())
    local Config = self._Config
    local MaxDelay = Config.MaxDelay

    if self._Combo == Table.count(Config.Combo) then
        self:_ResetCombo()
    end

    if self._FirstHitTime then
        if self._FirstHitTime + (MaxDelay * self._Combo) < os.clock() then
            self:_ResetCombo()
        end
    end

    self:_IncrementCombo()

    cb(self._Combo)
end

function DefaultBasicAttack._IsActive(self: Object): boolean
    return self._ActiveUntil > os.clock()
end

-- [ Public Functions ] --
function DefaultBasicAttack.new(params: New_Params): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object

    self._PositionHistoryService = params.PositionHistoryService

    self._WeaponData = params.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack

    self._ActiveUntil = 0
    self._FirstHitTime = nil
    self._Combo = 0

    return self
end

function DefaultBasicAttack.Use(self: Object, params: Use_Params)
    local Config = self._Config
    local ComboData = Config.Combo

    if self._ActiveUntil > os.clock() then
        return
    end
    self._ActiveUntil = math.huge

    self:_SetupCombo(function(comboNumber: number)
        local CurrentAbilityData = ComboData[comboNumber]
        self._ActiveUntil = os.clock() + CurrentAbilityData.Time
    end)
end

function DefaultBasicAttack.Apply(self: Object, params: Apply_Params)
    if not self:_IsActive() then
        return
    end

    if not self:_ValidateHit(params) then
        return
    end

    local Humanoid = params.Attacked:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    if Humanoid.Health < 0 then
        return
    end

    local Config = self._Config
    local Combo = self._Combo
    local CurrentComboData = Config.Combo[Combo]

    Humanoid.Health -= CurrentComboData.Damage
end

return DefaultBasicAttack :: Module
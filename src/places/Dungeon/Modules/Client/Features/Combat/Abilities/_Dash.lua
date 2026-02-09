--[=[
    @class Dash
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local CombatTypes = require("CombatTypes")
local ItemTypes = require("ItemTypes")
local ServiceBag = require("ServiceBag")
local AnimationClass = require("AnimationClass")
local TimeUtil = require("TimeUtil")
local AbilityConfig = require("AbilityConfig")

-- [ Constants ] --
local DashAbilityConfigData = AbilityConfig.Abilities["Dash"]

-- [ Variables ] --

-- [ Module Table ] --
local Dash = {
    AbilityName = "Dash"
}
Dash.__index = Dash

-- [ Types ] --
type End_Context = {
    Mode: CombatTypes.Mode
}
type Use_Context = {
    Mode: CombatTypes.Mode
}
type New_Context = {
    Attacker: Model,
    ItemData: ItemTypes.WeaponItemData,
    ServiceBag: ServiceBag.ServiceBag,

    OnUse: (context: CombatTypes.Context) -> (),
    OnEnd: (context: CombatTypes.Context) -> (),
    OnHit: (context: CombatTypes.Context) -> (),
}
export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CreatureServiceClient: typeof(require("CreatureServiceClient")),
    _EntityServiceClient: typeof(require("EntityServiceClient")),

    _Attacker: Model,
    _WeaponData: ItemTypes.WeaponItemData,
    _AnimationObject: AnimationClass.Object,

    _OnUse: (context: CombatTypes.Context) -> (),
    _OnEnd: (context: CombatTypes.Context) -> (),
    _OnHit: (context: CombatTypes.Context) -> (),

    AbilityName: string
}
export type Object = typeof(setmetatable({} :: ObjectData, Dash))
export type Module = typeof(Dash)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Dash.new(context: New_Context): Object
    local self = setmetatable({} :: any, Dash) :: Object

    self._ServiceBag = context.ServiceBag
    self._CreatureServiceClient = self._ServiceBag:GetService(require("CreatureServiceClient"))
    self._EntityServiceClient = self._ServiceBag:GetService(require("EntityServiceClient"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._AnimationObject = self._CreatureServiceClient:GetAnimationObject(self._Attacker)

    self._OnUse = context.OnUse
    self._OnEnd = context.OnEnd
    self._OnHit = context.OnHit

    return self
end

function Dash.Use(self: Object, context: Use_Context)
    if context.Mode == "FromClient" then
        local ServerTime = TimeUtil:GetTime()

        if not self._CreatureServiceClient:UseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = DashAbilityConfigData.Duration,
        }) then
            return
        end

        local World = self._EntityServiceClient:GetWorld()
        local Components = self._EntityServiceClient:GetComponents()
        local Entity = self._CreatureServiceClient:GetEntityFromCharacter(self._Attacker)

        local Humanoid = self._Attacker:FindFirstChild("Humanoid") :: Humanoid?

        if not Humanoid then
            return
        end

        local MoveDir = Humanoid.MoveDirection.Magnitude > 0.1 and Humanoid.MoveDirection or self._Attacker:GetPivot().LookVector
        local FlattenDir = Vector2.new(MoveDir.X, MoveDir.Z).Unit

        World:set(Entity, Components.Velocity, {
            VelocityType = "LinearVelocity",
            StartTime = TimeUtil:GetTime(),
            Mode = Enum.VelocityConstraintMode.Plane,
            PlaneVelocity = FlattenDir,
            PrimaryTangentAxis = Vector3.new(1, 0, 0),
            SecondaryTangentAxis = Vector3.new(0, 0, 1),
            StartSpeed = 50,
            Duration = DashAbilityConfigData.Duration,
            Curve = "Idk",
        })
    end
end

function Dash.End(self: Object, context: End_Context)
    
end

return Dash :: Module
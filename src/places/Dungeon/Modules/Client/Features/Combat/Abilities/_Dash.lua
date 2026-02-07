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

-- [ Constants ] --

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
        local PrimaryPart = self._Attacker.PrimaryPart

        if not PrimaryPart then
            return
        end
    end
end

function Dash.End(self: Object, context: End_Context)
    
end

return Dash :: Module
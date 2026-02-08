local Players = game:GetService("Players")
--[=[
    @class Parry
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
local AbilityConfig = require("AbilityConfig")
local TimeUtil = require("TimeUtil")

-- [ Constants ] --

-- [ Variables ] --
local ParryConfigData = AbilityConfig.Abilities["Parry"]

-- [ Module Table ] --
local Parry = {
    AbilityName = "Parry"
}
Parry.__index = Parry

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

export type Object = typeof(setmetatable({} :: ObjectData, Parry))
export type Module = typeof(Parry)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Parry.new(context: New_Context): Object
    local self = setmetatable({} :: any, Parry) :: Object

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

function Parry.Use(self: Object, context: Use_Context)
    if context.Mode == "FromClient" then
        local ServerTime = TimeUtil:GetTime()

        if not self._CreatureServiceClient:UseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = ParryConfigData.Duration,
        }) then
            return
        end
    
        self._OnUse({
            AbilityName = self.AbilityName
        })
    end
end

function Parry.End(self: Object, context: End_Context)
    if context.Mode == "FromClient" then
        if not self._CreatureServiceClient:EndAbility(self._Attacker, self.AbilityName) then
            return
        end

        self._OnEnd({
            AbilityName = self.AbilityName
        })

        self._CreatureServiceClient:EndAbility(self._Attacker, "Parry")
        self._CreatureServiceClient:StartAbilityCooldown(self._Attacker, "Parry")
    elseif context.Mode == "FromECS" then
        self._CreatureServiceClient:StartAbilityCooldown(self._Attacker, "Parry")
    end
end

return Parry :: Module
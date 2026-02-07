--[=[
    @class Parry
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ServiceBag = require("ServiceBag")
local AbilityConfig = require("AbilityConfig")
local CombatTypes = require("CombatTypes")

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
    ServiceBag: ServiceBag.ServiceBag,
    Attacker: Model,
    ItemData: ItemTypes.WeaponItemData,
}
export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CreatureServiceServer: typeof(require("CreatureServiceServer")),
    _Attacker: Model,
    _WeaponData: ItemTypes.WeaponItemData,
}
export type Object = typeof(setmetatable({} :: ObjectData, Parry))
export type Module = typeof(Parry)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Parry.new(context: New_Context): Object
    local self = setmetatable({} :: any, Parry) :: Object

    self._ServiceBag = context.ServiceBag
    self._CreatureServiceServer = self._ServiceBag:GetService(require("CreatureServiceServer"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData

    return self
end

function Parry.Use(self: Object, context: Use_Context)
    if context.Mode == "FromClient" then
        local ServerTime = workspace.DistributedGameTime

        if not self._CreatureServiceServer:UseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = ParryConfigData.Duration,
        }) then
            return
        end
    end
end

function Parry.End(self: Object, context: End_Context)
    if context.Mode == "FromClient" then
        self._CreatureServiceServer:EndAbility(self._Attacker, self.AbilityName)
        self._CreatureServiceServer:StartAbilityCooldown(self._Attacker, self.AbilityName)
    elseif context.Mode == "FromECS" then
        self._CreatureServiceServer:StartAbilityCooldown(self._Attacker, self.AbilityName)
    end
end

return Parry :: Module

--[=[
    @class DefaultBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local WeaponConfig = require("WeaponConfig")
local CombatUtil = require("CombatUtil")
local CombatTypes = require("CombatTypes")
local EntityTypesServer = require("EntityTypesServer")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DefaultBasicAttack = {
    AbilityName = "DefaultBasicAttack"
}
DefaultBasicAttack.__index = DefaultBasicAttack

-- [ Types ] --
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
type Hit_Context = {
    Mode: "FromServer",
    Attacked: Model,
    OnHit: (context: CombatTypes.Context) -> (),
} | {
    Mode: "FromClient",
    Attacked: Model,
    AttackerCFrame: CFrame,
    OnHit: (context: CombatTypes.Context) -> (),
}
type New_Context = {
    ServiceBag: ServiceBag.ServiceBag,
    Attacker: Model,
    ItemData: WeaponItemData,
}
export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PositionHistoryService: typeof(require("PositionHistoryService")),
    _CreatureServiceServer: typeof(require("CreatureServiceServer")),

    _Attacker: Model,
    _WeaponData: WeaponItemData,
    _Config: Config,
    AbilityName: string,
}
export type Object = typeof(setmetatable({} :: ObjectData, DefaultBasicAttack))
export type Module = typeof(DefaultBasicAttack)

-- [ Private Functions ] --

-- [ Public Functions ] --
function DefaultBasicAttack.new(context: New_Context): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object

    self._ServiceBag = context.ServiceBag
    self._PositionHistoryService = self._ServiceBag:GetService(require("PositionHistoryService"))
    self._CreatureServiceServer = self._ServiceBag:GetService(require("CreatureServiceServer"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._Config = WeaponConfig[self._WeaponData.Name].BasicAttack

    return self
end

function DefaultBasicAttack.Use(self: Object)
    if self._CreatureServiceServer:IsAbilityActive(self._Attacker) then
        return
    end

    local PreviousAbility = self._CreatureServiceServer:GetPreviousAbility(self._Attacker) :: EntityTypesServer.CurrentAbilityComponent?
    local ServerTime = workspace.DistributedGameTime
    local Config = self._Config
    local ComboData = Config.Combo
    local Combo = 1
    
    if PreviousAbility 
    and PreviousAbility.AbilityName == self.AbilityName 
    and PreviousAbility.StartTime + PreviousAbility.Duration + Config.MaxDelay >= ServerTime
    and PreviousAbility.Combo < #ComboData then
        Combo += PreviousAbility.Combo
        self._CreatureServiceServer:TryUseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = ComboData[Combo].Time,
            Combo = Combo,
        })
    else
        self._CreatureServiceServer:TryUseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = ComboData[Combo].Time,
            Combo = Combo,
        })
    end
end

function DefaultBasicAttack.End(self: Object)
    if not self._CreatureServiceServer:IsAbilityActive(self._Attacker, self.AbilityName) then
        return
    end

    self._CreatureServiceServer:TryEndAbility(self._Attacker, self.AbilityName)
end

function DefaultBasicAttack.Hit(self: Object, context: Hit_Context)
    if not self._CreatureServiceServer:IsAbilityActive(self._Attacker, self.AbilityName) then
        return
    end

    local CurrentAbility = self._CreatureServiceServer:GetCurrentAbility(self._Attacker) :: EntityTypesServer.CurrentAbilityComponent
    local OnHit:(CombatTypes.Context) -> () = context.OnHit
    local Config = self._Config
    local Combo = CurrentAbility.Combo
    local CurrentComboData = Config.Combo[Combo]

    if context.Mode == "FromClient" then
        if not CombatUtil:ValidateHit({
            Attacker = self._Attacker,
            Attacked = context.Attacked,
            ClientAttackerCFrame = context.AttackerCFrame,
            PositionHistoryService = self._PositionHistoryService,
            HitboxSize = CurrentComboData.Range,
            Mode = "FromClient",
        }) then
            return
        end
    else
        
    end

    local Info = self._CreatureServiceServer:DamageCreature(self._Attacker, context.Attacked, CurrentComboData.Damage)

    if not Info then
        return
    end

    OnHit({
        Attacker = self._Attacker,
        Attacked = context.Attacked,
        HitInfo = Info
    })
end

return DefaultBasicAttack :: Module
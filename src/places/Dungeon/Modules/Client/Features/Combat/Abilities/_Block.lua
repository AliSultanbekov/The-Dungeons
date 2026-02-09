--[=[
    @class Block
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
local AnimationConstants = require("AnimationConstants")
local TimeUtil = require("TimeUtil")

-- [ Constants ] --

-- [ Variables ] --
local BlockConfigData = AbilityConfig.Abilities["Block"]

-- [ Module Table ] --
local Block = {
    AbilityName = "Block"
}
Block.__index = Block

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
export type Object = typeof(setmetatable({} :: ObjectData, Block))
export type Module = typeof(Block)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Block._SetupAnimations(self: Object)
    local AnimationObject = self._AnimationObject
    AnimationObject:LoadAnimation(self.AbilityName, BlockConfigData.AnimationID)
end

function Block.new(context: New_Context): Object
    local self = setmetatable({} :: any, Block) :: Object

    self._ServiceBag = context.ServiceBag
    self._CreatureServiceClient = self._ServiceBag:GetService(require("CreatureServiceClient"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._AnimationObject = self._CreatureServiceClient:GetAnimationObject(self._Attacker)

    self._OnUse = context.OnUse
    self._OnEnd = context.OnEnd
    self._OnHit = context.OnHit

    self:_SetupAnimations()

    return self
end

function Block.Use(self: Object, context: Use_Context)
    if context.Mode == "FromClient" then
        local ServerTime = TimeUtil:GetTime()

        if not self._CreatureServiceClient:UseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = BlockConfigData.Duration,
            IsHeld = true,
        }) then
            return
        end
    
        self._OnUse({
            AbilityName = self.AbilityName
        })
    
        self._AnimationObject:PlayAnimation(self.AbilityName, AnimationConstants.CreatureLayers.Combat)
    end
end

function Block.End(self: Object, context: End_Context)
    if context.Mode == "FromClient" then
        if not self._CreatureServiceClient:EndAbility(self._Attacker, self.AbilityName) then
            return
        end

        self._OnEnd({
            AbilityName = self.AbilityName
        })

        self._CreatureServiceClient:EndAbility(self._Attacker, self.AbilityName)
        
        self._AnimationObject:StopAnimation(self.AbilityName, AnimationConstants.CreatureLayers.Combat)
    end
end

return Block :: Module
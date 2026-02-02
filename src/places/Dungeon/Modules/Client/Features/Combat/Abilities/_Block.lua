--[=[
    @class Block
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Block = {
    AbilityName = "Block"
}
Block.__index = Block

-- [ Types ] --
type WeaponItemData = ItemTypes.WeaponItemData
type End_Context = {
    OnEnd: (context: CombatTypes.Context) -> (),
    Mode: "FromServer" | "FromClient",
}
type Use_Context = {
    Attacker: Model,
    Mode: "FromServer" | "FromClient",

    OnUse: (context: CombatTypes.Context) -> (),
}
type New_Context = {
    ServiceBag: ServiceBag.ServiceBag,
    Attacker: Model,
    ItemData: WeaponItemData,
}
export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CreatureServiceClient: typeof(require("CreatureServiceClient")),
    _Attacker: Model,
    _WeaponData: WeaponItemData,
    _BlockTrack: AnimationTrack?
}
export type Object = typeof(setmetatable({} :: ObjectData, Block))
export type Module = typeof(Block)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Block.new(context: New_Context): Object
    local self = setmetatable({} :: any, Block) :: Object

    self._ServiceBag = context.ServiceBag
    self._CreatureServiceClient = self._ServiceBag:GetService(require("CreatureServiceClient"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._BlockTrack = nil

    return self
end

function Block.Use(self: Object, context: Use_Context)
    local Attacker = self._Attacker
    local Humanoid = Attacker:FindFirstChildOfClass("Humanoid")
    
    if not Humanoid then
        return
    end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")

    if not Animator then
        return
    end

    if context.Mode == "FromClient" then
        local ServerTime = workspace.DistributedGameTime

        if not self._CreatureServiceClient:TryUseAbility(self._Attacker, {
            AbilityName = self.AbilityName,
            StartTime = ServerTime,
            Duration = math.huge,
            IsHeld = true,
        }) then
            return
        end

        local AnimationID = "rbxassetid://87451259660096"
        local AnimationInstance = Instance.new("Animation"); AnimationInstance.AnimationId = AnimationID
        local Track = Animator:LoadAnimation(AnimationInstance)

        Track.Priority = Enum.AnimationPriority.Action
        Track:Play(0.15, 1, 0.3)
        self._BlockTrack = Track

        context.OnUse({
            AbilityName = self.AbilityName
        })
    end
end

function Block.End(self: Object, context: End_Context)

    local Attacker = self._Attacker
    local Humanoid = Attacker:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")

    if not Animator then
        return
    end

    if self._BlockTrack then
        self._BlockTrack:Stop()
        self._BlockTrack = nil
    end

    if context.Mode == "FromClient" then
        if not self._CreatureServiceClient:IsAbilityActive(self._Attacker, self.AbilityName) then
            print("S1")
            return
        end
        
        if not self._CreatureServiceClient:TryEndAbility(self._Attacker, self.AbilityName) then
            print("S2")
            return
        end

        context.OnEnd({
            AbilityName = self.AbilityName
        })
    end
end

return Block :: Module
--[=[
    @class Block
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Block = {
    AbilityName = "Block"
}
Block.__index = Block

-- [ Types ] --
type WeaponItemData = ItemTypes.WeaponItemData
type New_Context = {
    ServiceBag: ServiceBag.ServiceBag,
    Attacker: Model,
    ItemData: WeaponItemData,
}
export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CreatureServiceServer: typeof(require("CreatureServiceServer")),
    _Attacker: Model,
    _WeaponData: WeaponItemData,
}
export type Object = typeof(setmetatable({} :: ObjectData, Block))
export type Module = typeof(Block)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Block.new(context: New_Context): Object
    local self = setmetatable({} :: any, Block) :: Object

    self._ServiceBag = context.ServiceBag
    self._CreatureServiceServer = self._ServiceBag:GetService(require("CreatureServiceServer"))

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData

    return self
end

function Block.Use(self: Object)
    local ServerTime = workspace.DistributedGameTime
    
    self._CreatureServiceServer:TryUseAbility(self._Attacker, {
        AbilityName = "Block",
        StartTime = ServerTime,
        Duration = math.huge,
        IsHeld = true,
    })
end

function Block.End(self: Object)
    if not self._CreatureServiceServer:IsAbilityActive(self._Attacker, self.AbilityName) then
        return
    end

    self._CreatureServiceServer:TryEndAbility(self._Attacker, self.AbilityName)
end

return Block :: Module
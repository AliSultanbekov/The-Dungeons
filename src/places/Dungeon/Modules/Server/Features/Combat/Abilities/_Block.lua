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
local AbilityConfig = require("AbilityConfig")
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
    local ServerTime = TimeUtil:GetTime()
    
    if not self._CreatureServiceServer:UseAbility(self._Attacker, {
        AbilityName = self.AbilityName,
        StartTime = ServerTime,
        Duration = BlockConfigData.Duration,
        IsHeld = true,
    }) then
        return
    end

end

function Block.End(self: Object)
    self._CreatureServiceServer:EndAbility(self._Attacker, self.AbilityName)
end

return Block :: Module
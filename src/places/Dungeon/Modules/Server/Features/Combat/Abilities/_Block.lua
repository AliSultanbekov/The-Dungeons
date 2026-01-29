--[=[
    @class Block
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Block = {
    AbilityName = "Block"
}
Block.__index = Block

-- [ Types ] --
type AbilityState = {
    Name: string,
    StartTime: number,
    Combo: number,
    Duration: number,
}
type CreatureServiceServer = typeof(require("CreatureServiceServer"))
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
type New_Context = {
    Attacker: Model,
    ItemData: WeaponItemData,
    CreatureService: CreatureServiceServer,
}
export type ObjectData = {
    _Attacker: Model,
    _WeaponData: WeaponItemData,
    _CreatureServiceServer: CreatureServiceServer
}
export type Object = typeof(setmetatable({} :: ObjectData, Block))
export type Module = typeof(Block)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Block.new(context: New_Context): Object
    local self = setmetatable({} :: any, Block) :: Object

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._CreatureServiceServer = context.CreatureService

    return self
end

function Block.IsActive(self: Object): boolean
    local CurrentAbility = self._CreatureServiceServer:GetCurrentAbility(self._Attacker) :: AbilityState?

    if not CurrentAbility then
        return false
    end

    if CurrentAbility.Name ~= self.AbilityName then
        return false
    end

    return true
end

function Block.Use(self: Object)
    if self:IsActive() then
        return
    end
    
    if self._CreatureServiceServer:TryUseAbility(self._Attacker, {
        AbilityName = "Block",
        StartTime = os.clock(),
        Duration = 5,
    }) then
        print("Blocked")
    end
end

function Block.End()
    
end

return Block :: Module
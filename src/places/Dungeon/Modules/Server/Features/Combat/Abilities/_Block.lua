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
type PositionHistoryService = typeof(require("PositionHistoryService"))
type CombatEntityStateService = typeof(require("CombatEntityStateServiceServer"))
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
    PositionHistoryService: PositionHistoryService,
    CombatEntityStateService: CombatEntityStateService,
}
export type ObjectData = {
    
}
export type Object = typeof(setmetatable({} :: ObjectData, Block))
export type Module = typeof(Block)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Block.new(context: New_Context): Object
    local self = setmetatable({} :: any, Block) :: Object

    return self
end

return Block :: Module
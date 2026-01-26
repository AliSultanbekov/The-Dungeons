--[=[
    @class Block
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
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
type CombatEntityStateService = typeof(require("CombatEntityStateServiceClient"))
type WeaponItemData = ItemTypes.WeaponItemData
type Use_Context = {
    Attacker: Model,
    Mode: "FromServer" | "FromClient",

    OnUse: (context: CombatTypes.Context) -> (),
    OnEnd: (context: CombatTypes.Context) -> (),
    OnHit: (context: CombatTypes.Context) -> (),
}
type New_Context = {
    Attacker: Model,
    ItemData: WeaponItemData,
    CombatEntityStateService: CombatEntityStateService,
}
export type ObjectData = {
    _Attacker: Model,
    _WeaponData: WeaponItemData,
    _CombatEntityStateService: CombatEntityStateService
}
export type Object = typeof(setmetatable({} :: ObjectData, Block))
export type Module = typeof(Block)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Block.new(context: New_Context): Object
    local self = setmetatable({} :: any, Block) :: Object

    self._Attacker = context.Attacker
    self._WeaponData = context.ItemData
    self._CombatEntityStateService = context.CombatEntityStateService

    return self
end

function Block.Use(self: Object, context: Use_Context)
    if context.Mode == "FromClient" then
        context.OnUse({
            AbilityName = self.AbilityName
        })
    end
end

return Block :: Module
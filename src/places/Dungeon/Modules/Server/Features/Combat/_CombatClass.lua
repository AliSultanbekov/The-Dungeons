--[=[
    @class CombatClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local AbilityManager = require("./_AbilityManager")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatClass = {}
CombatClass.__index = CombatClass

-- [ Types ] --
type AbilityObject = CombatTypes.AbilityObject
type AbilityManagerObject = AbilityManager.Object
export type ObjectData = {
    _Character: Model,
    _AbilityManager: AbilityManagerObject,

    _BasicAttack: AbilityObject?,
    _SpecialAttack: AbilityObject?,
}
export type Object = ObjectData & {
    
}
export type Module = {
    __index: Module,
    new: (character: Model, abilityManager: AbilityManagerObject) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatClass.new(character: Model, abilityManager: AbilityManagerObject): Object
    local self = setmetatable({} :: any, CombatClass) :: Object

    self._Character = character
    self._AbilityManager = abilityManager

    self._BasicAttack = nil
    self._SpecialAttack = nil

    return self
end

function CombatClass.SetActiveWeapon(self: Object, weaponName: string)
    
end

return CombatClass :: Module
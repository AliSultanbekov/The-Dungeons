--[=[
    @class WoodenSwordBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local CombatTypes = require("CombatTypes")
local SharedModule = require("WoodenSwordBasicAttackShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WoodenSwordBasicAttack = {}
WoodenSwordBasicAttack.__index = WoodenSwordBasicAttack

-- [ Types ] --
type Activate_Context = CombatTypes.ServerActivate_Context
type AbilityObject = CombatTypes.ServerAbilityObject
type Config = {
    Range: number,
    MinDot: number,
    Animation: string,
    Name: string,
    Damage: number,
}
export type ObjectData = {
    _Config: Config
}
export type Object = ObjectData & AbilityObject & {
    
}
export type Module = {
    __index: Module,
    new: (config: Config) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function WoodenSwordBasicAttack.new(config: Config): Object
    local self = setmetatable({} :: any, WoodenSwordBasicAttack) :: Object

    self._Config = config

    return self
end

function WoodenSwordBasicAttack.Activate(self: Object, context: Activate_Context)
    SharedModule:Validate({
        Attacker = context.Attacker,
        Config = self._Config,
        Hits = context.Hits,
    })
    
    for _, attacked in context.Hits do
        local Humanoid = attacked:FindFirstChildOfClass("Humanoid")

        if not Humanoid then return end

        Humanoid.Health -= 10
    end
end

return WoodenSwordBasicAttack :: Module
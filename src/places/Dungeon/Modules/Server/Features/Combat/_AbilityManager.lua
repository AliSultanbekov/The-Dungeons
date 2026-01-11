--[=[
    @class AbilityManager
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local rbxrequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --
local Abilities = script.Parent.Abilities

-- [ Module Table ] --
local AbilityManager = {}
AbilityManager.__index = AbilityManager

-- [ Types ] --
type AbilityModule = CombatTypes.AbilityModule
export type ObjectData = {
    _Abilities: {
        [string]: AbilityModule
    }
}
export type Object = ObjectData & {
    _LoadAbilities: (self: Object) -> (),
    GetAbility: (self: Object, abilityName: string) -> AbilityModule
}
export type Module = {
    __index: Module,
    new: () -> Object
}

-- [ Private Functions ] --
function AbilityManager._LoadAbilities(self: Object)
    for _, instance in Abilities:GetChildren() do
        if not instance:IsA("ModuleScript") then
            continue
        end

        local AbilityModule: AbilityModule = rbxrequire(instance)

        self._Abilities[instance.Name] = AbilityModule
    end
end

-- [ Public Functions ] --
function AbilityManager.new(): Object
    local self = setmetatable({} :: any, AbilityManager) :: Object

    self._Abilities = {}

    self:_LoadAbilities()

    return self
end

function AbilityManager.GetAbility(self: Object, abilityName: string): AbilityModule
    return self._Abilities[string.format("_%s%s", abilityName, "Client")]
end

return AbilityManager :: Module
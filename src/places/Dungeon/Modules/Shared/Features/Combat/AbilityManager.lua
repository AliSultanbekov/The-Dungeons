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

-- [ Module Table ] --
local AbilityManager = {}
AbilityManager.__index = AbilityManager

-- [ Types ] --
type AbilityModule = CombatTypes.ClientAbilityModule
export type ObjectData = {
    _Abilties: {
        [string]: AbilityModule
    }
}
export type Object = ObjectData & {
    _LoadAbilities: (self: Object, abilityFolder: Folder) -> (),
    Get: (self: Object, abilityName: string) -> AbilityModule,
}
export type Module = {
    __index: Module,
    new: (abilityFolder: Folder) -> Object
}

-- [ Private Functions ] --
function AbilityManager._LoadAbilities(self: Object, abilityFolder: Folder)
    for _, instance in abilityFolder:GetChildren() do
        if not instance:IsA("ModuleScript") then
            continue
        end

        if instance.Name == "loader" then
            continue
        end

        local AbilityModule: AbilityModule = rbxrequire(instance)

        self._Abilties[AbilityModule.AbilityName] = AbilityModule
    end
end

-- [ Public Functions ] --
function AbilityManager.new(abilityFolder: Folder): Object
    local self = setmetatable({} :: any, AbilityManager) :: Object

    self._Abilties = {}

    self:_LoadAbilities(abilityFolder)

    return self
end

function AbilityManager.Get(self: Object, abilityName: string): AbilityModule
    print(self._Abilties)
    return self._Abilties[abilityName]
end

return AbilityManager :: Module
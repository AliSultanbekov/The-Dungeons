--[=[
    @class WeaponUIBehavior
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WeaponUIBehavior = {}
WeaponUIBehavior.__index = WeaponUIBehavior

-- [ Types ] --
export type ObjectData = {

}
export type Object = {
    
}
export type Module = {
    __index: Module,
    new: () -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeaponUIBehavior.new(): Object
    local self = setmetatable({} :: any, WeaponUIBehavior) :: Object

    return self
end

return WeaponUIBehavior :: Module
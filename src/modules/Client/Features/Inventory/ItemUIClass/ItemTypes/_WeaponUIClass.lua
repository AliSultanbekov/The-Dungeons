--[=[
    @class WeaponUIClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WeaponUIClass = {}
WeaponUIClass.__index = WeaponUIClass

-- [ Types ] --
export type ObjectData = {

}
export type Object = ObjectData & Module
export type Module = typeof(WeaponUIClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeaponUIClass.new(): Object
    local self = setmetatable({} :: any, WeaponUIClass) :: Object

    return self
end

return WeaponUIClass :: Module
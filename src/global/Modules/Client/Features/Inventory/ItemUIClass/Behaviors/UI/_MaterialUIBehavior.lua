--[=[
    @class MaterialUIClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MaterialUIClass = {}
MaterialUIClass.__index = MaterialUIClass

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
function MaterialUIClass.new(): Object
    local self = setmetatable({} :: any, MaterialUIClass) :: Object

    return self
end

return MaterialUIClass :: Module
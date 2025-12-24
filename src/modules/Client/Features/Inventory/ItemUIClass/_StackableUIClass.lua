--[=[
    @class StackableUIClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StackableUIClass = {}
StackableUIClass.__index = StackableUIClass

-- [ Types ] --
export type ObjectData = {

}
export type Object = ObjectData & Module
export type Module = typeof(StackableUIClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function StackableUIClass.new(): Object
    local self = setmetatable({} :: any, StackableUIClass) :: Object

    return self
end

return StackableUIClass :: Module
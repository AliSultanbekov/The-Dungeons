--[=[
    @class ItemUIClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemUIClass = {}
ItemUIClass.__index = ItemUIClass

-- [ Types ] --
export type ObjectData = {

}
export type Object = ObjectData & Module
export type Module = typeof(ItemUIClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function ItemUIClass.new(): Object
    local self = setmetatable({} :: any, ItemUIClass) :: Object

    return self
end

return ItemUIClass :: Module
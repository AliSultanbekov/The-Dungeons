--[=[
    @class WoodenSwordBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WoodenSwordBasicAttack = {}
WoodenSwordBasicAttack.__index = WoodenSwordBasicAttack

-- [ Types ] --
export type ObjectData = {

}
export type Object = ObjectData & {
    
}
export type Module = {
    __index: Module,
    new: () -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function WoodenSwordBasicAttack.new(): Object
    local self = setmetatable({} :: any, WoodenSwordBasicAttack) :: Object

    return self
end

return WoodenSwordBasicAttack :: Module
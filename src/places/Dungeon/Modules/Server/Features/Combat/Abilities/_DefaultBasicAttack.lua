--[=[
    @class DefaultBasicAttack
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DefaultBasicAttack = {}
DefaultBasicAttack.__index = DefaultBasicAttack

-- [ Types ] --
type Use_Params = {

}
type Apply_Params = {
    attacker: Model,
    attacked: Model,
}
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
function DefaultBasicAttack.new(): Object
    local self = setmetatable({} :: any, DefaultBasicAttack) :: Object

    return self
end

function DefaultBasicAttack.Use(self: Object, params: Use_Params)
    print("used")
end

function DefaultBasicAttack.Apply(self: Object, params: Apply_Params)
    
end

return DefaultBasicAttack :: Module
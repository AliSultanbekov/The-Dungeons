--[=[
    @class DefaultBlock
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DefaultBlock = {}
DefaultBlock.__index = DefaultBlock

-- [ Types ] --
type Use_Params = {
    Mode: "FromServer" | "FromClient"
}
export type ObjectData = {
    
}
export type Object = typeof(setmetatable({} :: ObjectData, DefaultBlock))
export type Module = typeof(DefaultBlock)

-- [ Private Functions ] --

-- [ Public Functions ] --
function DefaultBlock.new(): Object
    local self = setmetatable({} :: any, DefaultBlock) :: Object

    

    return self
end

function DefaultBlock.Use(self: Object, params: Use_Params)
    
end

function DefaultBlock.End(self: Object)
    
end

function DefaultBlock.Hit(self: Object)
    
end

return DefaultBlock :: Module
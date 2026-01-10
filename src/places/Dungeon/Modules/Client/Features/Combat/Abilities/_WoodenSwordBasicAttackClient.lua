--[=[
    @class WoodenSwordBasicAttackClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local SharedModule = require("WoodenSwordBasicAttackShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WoodenSwordBasicAttackClient = {}
WoodenSwordBasicAttackClient.__index = WoodenSwordBasicAttackClient

-- [ Types ] --
type Config = {
    Name: string,
    Combo: { 
        [number]: {
            Animation: string,
            Damage: number
        }
    }
}
export type ObjectData = {
    _Config: Config,
    _Active: boolean,
}
export type Object = ObjectData & {

}
export type Module = {
    __index: Module,
    new: (config: Config) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function WoodenSwordBasicAttackClient.new(config: Config): Object
    local self = setmetatable({} :: any, WoodenSwordBasicAttackClient) :: Object

    self._Config = config
    self._Active = false

    return self
end

function WoodenSwordBasicAttackClient.Activate(self: Object, context: { Attacker: Model })
    if self._Active == true then
        return
    end

    self._Active = true

    local _Hits = SharedModule:DetectHits(context.Attacker)

    task.delay(2, function()
        self._Active = false
    end)
end

return WoodenSwordBasicAttackClient :: Module
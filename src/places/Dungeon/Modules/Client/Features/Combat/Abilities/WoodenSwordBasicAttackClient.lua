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

-- [ Types ] --
export type Module = typeof(WoodenSwordBasicAttackClient)

-- [ Private Functions ] --

-- [ Public Functions ] --
function WoodenSwordBasicAttackClient.Activate(self: Module, context: { Attacker: Model })
    local Hits = SharedModule:DetectHits(context.Attacker)

    print(Hits)
end

return WoodenSwordBasicAttackClient :: Module
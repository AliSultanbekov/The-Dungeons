--[=[
    @class DamageBuffSystem
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local EntityTypesServer = require("EntityTypesServer")
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DamageBuffSystem = {}

-- [ Types ] --
type ModuleData = {
    _World: Jecs.World,
    _Tags: EntityTypesServer.Tags,
    _Components: EntityTypesServer.Components,
    _Signals: EntityTypesServer.PublicSignals,
}

export type Module = typeof(DamageBuffSystem) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function DamageBuffSystem.Update(self: Module, dt: number)
    local World = self._World
    local Components = self._Components

    for Entity, DamageBuff: EntityTypesServer.DamageBuffComponent in World:query(Components.DamageBuff) do
        if DamageBuff.StartTime + DamageBuff.Duration < os.clock() then
            World:remove(Entity, Components.DamageBuff)
        end
    end
end

function DamageBuffSystem.Init(self: Module, context: EntityTypesServer.SystemModule_Init_Context)
    self._World = context.World
    self._Tags = context.Tags
    self._Components = context.Components
    self._Signals = context.Signals
end

return DamageBuffSystem :: Module
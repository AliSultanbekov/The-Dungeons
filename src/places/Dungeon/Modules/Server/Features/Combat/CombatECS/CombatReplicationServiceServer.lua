--[=[
    @class CombatReplicationServiceServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CombatReplicationServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatEntityServiceServer: typeof(require("CombatEntityServiceServer")),
    _CombatNetworkServer: typeof(require("CombatNetworkServer")),
}

export type Module = typeof(CombatReplicationServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatReplicationServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatEntityServiceServer = self._ServiceBag:GetService(require("CombatEntityServiceServer"))
    self._CombatNetworkServer = self._ServiceBag:GetService(require("CombatNetworkServer"))
end

function CombatReplicationServiceServer.Start(self: Module)
    local World = self._CombatEntityServiceServer:GetWorld()
    local Tags = self._CombatEntityServiceServer:GetTags()

    for component in World:query(Tags.Replicated) do
        World:added(component, function(e, id, value)
            self._CombatNetworkServer:EntityStateUpdated({
                Action = "Added",
                Data = {
                    Entity = e,
                    Component = id,
                    Value = value
                }
            })
        end)

        World:removed(component, function(e, id)
            self._CombatNetworkServer:EntityStateUpdated({
                Action = "Removed",
            })
        end)    

        World:changed(component, function(e, id, value)
            self._CombatNetworkServer:EntityStateUpdated({
                Action = "Updated",
                Data = {
                    Entity = e,
                    Component = id,
                    Value = value
                }
            })
        end)
    end
end

return CombatReplicationServiceServer :: Module
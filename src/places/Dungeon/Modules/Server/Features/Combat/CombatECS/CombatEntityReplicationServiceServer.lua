--[=[
    @class CombatEntityReplicationServiceServer
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
local CombatEntityReplicationServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CombatEntityServiceServer: typeof(require("CombatEntityServiceServer")),
    _CombatNetworkServer: typeof(require("CombatNetworkServer")),
}

export type Module = typeof(CombatEntityReplicationServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CombatEntityReplicationServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CombatEntityServiceServer = self._ServiceBag:GetService(require("CombatEntityServiceServer"))
    self._CombatNetworkServer = self._ServiceBag:GetService(require("CombatNetworkServer"))
end

function CombatEntityReplicationServiceServer.Start(self: Module)
    local World = self._CombatEntityServiceServer:GetWorld()
    local Tags = self._CombatEntityServiceServer:GetTags()

    -- TODO: setup optimization

    for component in World:query(Tags.Replicated) do
        World:added(component, function(e, _, value)
            self._CombatNetworkServer:EntityStateUpdated({
                Action = "Added",
                Data = {
                    Entity = e,
                    Component = component,
                    Value = value
                }
            })
        end)

        World:removed(component, function(e, _)
            self._CombatNetworkServer:EntityStateUpdated({
                Action = "Removed",
                Data = {
                    Entity = e,
                    Component = component,
                }
            })
        end)    

        World:changed(component, function(e, _, value)
            self._CombatNetworkServer:EntityStateUpdated({
                Action = "Updated",
                Data = {
                    Entity = e,
                    Component = component,
                    Value = value
                }
            })
        end)
    end
end

return CombatEntityReplicationServiceServer :: Module
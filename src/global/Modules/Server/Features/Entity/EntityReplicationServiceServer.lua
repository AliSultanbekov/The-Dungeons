--[=[
    @class EntityReplicationServiceServer
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
local EntityReplicationServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _EntityServiceServer: typeof(require("EntityServiceServer")),
    _EntityNetworkServer: typeof(require("EntityNetworkServer")),
}

export type Module = typeof(EntityReplicationServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EntityReplicationServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._EntityServiceServer = self._ServiceBag:GetService(require("EntityServiceServer"))
    self._EntityNetworkServer = self._ServiceBag:GetService(require("EntityNetworkServer"))
end

function EntityReplicationServiceServer.Start(self: Module)
    local World = self._EntityServiceServer:GetWorld()
    local Tags = self._EntityServiceServer:GetTags()

    -- TODO: setup optimization
    for component in World:query(Tags.Replicated) do
        World:added(component, function(e, _, value)
            self._EntityNetworkServer:ReplicateComponentChange({
                Action = "Added",
                Data = {
                    Entity = e,
                    Component = component,
                    Value = value
                }
            })
        end)

        World:removed(component, function(e, _)
            self._EntityNetworkServer:ReplicateComponentChange({
                Action = "Removed",
                Data = {
                    Entity = e,
                    Component = component,
                }
            })
        end)    

        World:changed(component, function(e, _, value)
            self._EntityNetworkServer:ReplicateComponentChange({
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

return EntityReplicationServiceServer :: Module
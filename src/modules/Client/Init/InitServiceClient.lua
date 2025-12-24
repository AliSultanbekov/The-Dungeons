--[=[
    @class InitServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --
local Features = script.Parent.Parent.Features

-- [ Module Table ] --
local InitServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(InitServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InitServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._ServiceBag:GetService(require("CmdrServiceClient"))

    for _, instance in Features:GetDescendants() do
        if instance:IsA("ModuleScript") and (instance.Name:lower():find("service") or instance.Name:lower():find("controller") or instance.Name:lower():find("eventbus")) then
            self._ServiceBag:GetService(instance)
        end
    end

    print("[Framework] Initialized")
end

function InitServiceClient.Start(self: Module)
    
end

return InitServiceClient :: Module
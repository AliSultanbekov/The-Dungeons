--[=[
    @class NetworkService
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NetworkService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Networks: { [string]: Remoting.Remoting },
}

export type Module = typeof(NetworkService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function NetworkService.GetNetwork(self: Module, networkName: string): Remoting.Remoting
    local Network = self._Networks[networkName]

    if not Network then
        Network = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), networkName)
    end

    self._Networks[networkName] = Network
    
    return Network
end

function NetworkService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Networks = {}
end

return NetworkService :: Module
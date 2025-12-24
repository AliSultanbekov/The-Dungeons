--[=[
    @class HitboxService
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
local HitboxService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(HitboxService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function HitboxService.Apply()
    
end

function HitboxService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function HitboxService.Start(self: Module)
    
end

return HitboxService :: Module
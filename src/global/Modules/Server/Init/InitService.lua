--[=[
    @class InitService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local PlaceConstants = require("PlaceConstants")
local InitUtils = require("InitUtils")

-- [ Constants ] --
local ModulesFolder = script.Parent.Parent.Parent.Parent

-- [ Variables ] --

-- [ Module Table ] --
local InitService = {}

-- [ Types ] --
type ModulesFolder = typeof(ModulesFolder)
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(InitService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InitService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")

    local Modules = InitUtils:GetContextModules(ModulesFolder, PlaceConstants.PlaceIDToPlaceName[game.PlaceId], "Server")

    for _, module in Modules do
        self._ServiceBag:GetService(module)
    end
end

function InitService.Start(self: Module)

end

return InitService :: Module
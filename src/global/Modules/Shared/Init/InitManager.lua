--[=[
    @class InitControllerClient
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local PlaceConstants = require("PlaceConstants")
local InitUtil = require("InitUtil")
local Jabby = require("Jabby")

-- [ Constants ] --

-- [ Variables ] --
local ModulesFolder = script.Parent.Parent.Parent.Parent

-- [ Module Table ] --
local InitControllerClient = {}

-- [ Types ] --
type ModulesFolder = typeof(ModulesFolder)
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(InitControllerClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InitControllerClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    local Modules = InitUtil:GetContextModules(ModulesFolder, PlaceConstants.PlaceIDToPlaceName[game.PlaceId])

    for _, module in Modules do
        self._ServiceBag:GetService(module)
    end
end

function InitControllerClient.Start(self: Module)
    task.spawn(function()
        if RunService:IsClient() then
            local client = Jabby.obtain_client()
        
            local function create_widget(_, state: Enum.UserInputState)
                if state ~= Enum.UserInputState.Begin then return end
                client.spawn_app((client.apps.home) :: any, nil)
            end
            
            ContextActionService:BindAction("Open Jabby Home", create_widget, false, Enum.KeyCode.F4)
        end
    end)
end

return InitControllerClient :: Module
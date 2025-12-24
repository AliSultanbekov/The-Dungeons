--[=[
    @class SoundServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ObjectPool = require("ObjectPool")
local AssetProvider = require("AssetProvider")
local WorkspaceFactory = require("WorkspaceFactory")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local SoundServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ObjectPool: ObjectPool.Object<Sound>,
    _WorkspaceRefs: WorkspaceFactory.Refs,
}

export type Module = typeof(SoundServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function SoundServiceClient.PlaySound(self: Module, soundName: string)
    if not self._ObjectPool:KeyExists(soundName) then
        self._ObjectPool:AddKey(
            soundName,
            function()
                return AssetProvider:Get({"Sounds", soundName})
            end,
            function(obj: Sound)
                obj:Stop()
                obj.Parent = nil
            end
        )
    end
    
    local Sound = self._ObjectPool:Get(soundName)

    Sound.Parent = self._WorkspaceRefs.Sounds

    Sound:Play()

    local Conn; Conn = Sound.Ended:Connect(function()
        if Conn then
            Conn:Disconnect()
        end

        self._ObjectPool:Return(soundName, Sound)
    end)
end

function SoundServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ObjectPool = ObjectPool.new()
    self._WorkspaceRefs = WorkspaceFactory:ProduceRefs()
end

function SoundServiceClient.Start(self: Module)
    
end

return SoundServiceClient :: Module
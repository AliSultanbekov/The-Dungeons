--[=[
    @class SoundManager
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ObjectPool = require("ObjectPool")
local AssetProvider = require("AssetProvider")

-- [ Constants ] --

-- [ Variables ] --
local World = workspace.World

-- [ Module Table ] --
local SoundManager = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ObjectPool: ObjectPool.Object<Sound>,
}

export type Module = typeof(SoundManager) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function SoundManager.PlaySound(self: Module, soundName: string)
    if not self._ObjectPool:KeyExists(soundName) then
        self._ObjectPool:AddKey(
            soundName,
            function()
                return AssetProvider:Get(string.format("Sounds/%s", soundName))
            end,
            function(obj: Sound)
                obj:Stop()
                obj.Parent = nil
            end
        )
    end
    
    local Sound = self._ObjectPool:Get(soundName)

    Sound.Parent = World.Sounds

    Sound:Play()

    local Conn; Conn = Sound.Ended:Connect(function()
        if Conn then
            Conn:Disconnect()
        end

        self._ObjectPool:Return(soundName, Sound)
    end)
end

function SoundManager.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ObjectPool = ObjectPool.new()
end

function SoundManager.Start(self: Module)
    
end

return SoundManager :: Module
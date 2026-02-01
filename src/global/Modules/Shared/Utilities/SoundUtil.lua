--[=[
    @class SoundUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ObjectPool = require("ObjectPool")
local AssetProvider = require("AssetProvider")

-- [ Constants ] --

-- [ Variables ] --
local Pool = ObjectPool.new()

-- [ Module Table ] --
local SoundUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(SoundUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function SoundUtil.PlaySound(self: Module, soundPath: string)
    if not Pool:KeyExists(soundPath) then
        Pool:AddKey(
            soundPath,
            function()
                return AssetProvider:Get(string.format("Sounds/%s", soundPath))
            end,
            function(obj: Sound)
                obj:Stop()
                obj.Parent = nil
            end
        )
    end
    
    local Sound = Pool:Get(soundPath)

    Sound.Parent = workspace.World.Sounds

    Sound:Play()

    Sound.Ended:Once(function()
        Pool:Return(soundPath, Sound)
    end)
end

return SoundUtil :: Module
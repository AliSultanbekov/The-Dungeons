--[=[
    @class VFXClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local AssetProvider = require("AssetProvider")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local VFXClass = {}
VFXClass.__index = VFXClass

-- [ Types ] --
type Params = {
    Cleanup: number?,
}
export type ObjectData = {
    _VFX: {
        ParticleEmitter
    },
    _Params: Params,
}
export type Object = typeof(setmetatable({} :: ObjectData, VFXClass))
export type Module = typeof(VFXClass)

-- [ Private Functions ] --
function VFXClass._ProcessPaths(self: Object, paths: { string }, container: Instance): { ParticleEmitter }
    local Particles = {}

    for _, path in paths do
        local Instance = AssetProvider:Get(path) :: Folder | ParticleEmitter

        local function process(instance: Folder | ParticleEmitter)
            if instance:IsA("ParticleEmitter") then
                instance.Parent = container
                table.insert(Particles, instance)
            else
                for _, child in instance:GetChildren() do
                    process((child :: Folder | ParticleEmitter))
                end
            end
        end

        process(Instance)
    end

    return Particles
end

-- [ Public Functions ] --
function VFXClass.new(paths: { string }, container: Instance, params: Params?): Object
    local self = setmetatable({} :: any, VFXClass) :: Object

    self._VFX = self:_ProcessPaths(paths, container)
    self._Params = params or {}

    if self._Params.Cleanup then
        task.delay(self._Params.Cleanup, function()
            self:Destroy()
        end)
    end

    return self
end

function VFXClass.Emit(self: Object, count: number?)
    for _, particle in self._VFX do
        local Count = count or (particle:GetAttribute("EmitCount") :: number) or 1
        particle:Emit(Count)
    end
end

function VFXClass.Destroy(self: Object)
    for _, particle in self._VFX do
        particle:Destroy()
    end
end

return VFXClass :: Module
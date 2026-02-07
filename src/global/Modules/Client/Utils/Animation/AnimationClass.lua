--[=[
    @class AnimationClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --


-- [ Variables ] --

-- [ Module Table ] --
local AnimationClass = {}
AnimationClass.__index = AnimationClass

-- [ Types ] -- 
export type ObjectData = {
    _Animator: Animator,
    _ActiveLayers: { [number]: AnimationTrack },
    _Tracks: {
        [string]: AnimationTrack
    }
}
export type Object = typeof(setmetatable({} :: ObjectData, AnimationClass))
export type Module = typeof(AnimationClass)

-- [ Private Functions ] --
function AnimationClass._FindAnimator(self: Object, character: Model)
    local Humanoid = character:WaitForChild("Humanoid") :: Humanoid

    if not Humanoid then
        error("[AnimationClass] No Humanoid found in character")
    end

    local Animator = Humanoid:WaitForChild("Animator") :: Animator

    if not Animator then
        error("[AnimationClass] No Animator found in character")
    end

    return Animator
end

-- [ Public Functions ] --
function AnimationClass.new(character: Model): Object
    local self = setmetatable({} :: any, AnimationClass) :: Object

    self._Animator = self:_FindAnimator(character)
    self._Tracks = {}
    self._ActiveLayers = {}

    return self
end

function AnimationClass.MarkerReachedSignal(self: Object, animationName: string, eventName: string): RBXScriptSignal<...any>
    local Track = self._Tracks[animationName]

    if not Track then
        error(("[AnimationClass] No animation track found for name '%s'"):format(animationName))
    end

    return Track:GetMarkerReachedSignal(eventName)
end

function AnimationClass.UnloadAnimation(self: Object, animationName: string)
    local Track = self._Tracks[animationName]

    if not Track then
        return
    end

    for key, track in self._ActiveLayers do
        if track == Track then
            self._ActiveLayers[key] = nil
            break
        end
    end

    Track:Stop()
    Track:Destroy()
end

function AnimationClass.LoadAnimation(self: Object, animationName: string, animationID: string)
    local Animation = Instance.new("Animation")
    Animation.AnimationId = animationID

    local Track = self._Animator:LoadAnimation(Animation)

    self._Tracks[animationName] = Track
end

function AnimationClass.PlayAnimation(self: Object, animationName: string, animationLayer: number)
    local OldTrack = self._ActiveLayers[animationLayer]

    if OldTrack then
        OldTrack:Stop()
    end

    local NewTrack = self._Tracks[animationName]
    NewTrack:Play()

    self._ActiveLayers[animationLayer] = NewTrack
end

function AnimationClass.StopAnimation(self: Object, animationName: string, animationLayer: number)
    local Track = self._Tracks[animationName]

    if not Track then
        return
    end

    local ActiveTrack = self._ActiveLayers[animationLayer]

    if not ActiveTrack or Track ~= ActiveTrack then
        return
    end

    ActiveTrack:Stop()
end

return AnimationClass :: Module
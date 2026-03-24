--[=[
    @class AnimatorClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --


-- [ Variables ] --

-- [ Module Table ] --
local AnimatorClass = {}
AnimatorClass.__index = AnimatorClass

-- [ Types ] -- 
export type ObjectData = {
    _Animator: Animator,
    _ActiveLayers: { [number]: AnimationTrack },
    _Tracks: {
        [string]: AnimationTrack
    }
}
export type Object = typeof(setmetatable({} :: ObjectData, AnimatorClass))
export type Module = typeof(AnimatorClass)

-- [ Private Functions ] --
function AnimatorClass._FindAnimator(self: Object, character: Model)
    local Humanoid = character:WaitForChild("Humanoid") :: Humanoid

    if not Humanoid then
        error("[AnimatorClass] No Humanoid found in character")
    end

    local Animator = Humanoid:WaitForChild("Animator") :: Animator

    if not Animator then
        error("[AnimatorClass] No Animator found in character")
    end

    return Animator
end

-- [ Public Functions ] --
function AnimatorClass.new(character: Model): Object
    local self = setmetatable({} :: any, AnimatorClass) :: Object

    self._Animator = self:_FindAnimator(character)
    self._Tracks = {}
    self._ActiveLayers = {}

    return self
end

function AnimatorClass.MarkerReachedSignal(self: Object, animationName: string, eventName: string): RBXScriptSignal<...any>
    local Track = self._Tracks[animationName]

    if not Track then
        error(("[AnimatorClass] No animation track found for name '%s'"):format(animationName))
    end

    return Track:GetMarkerReachedSignal(eventName)
end

function AnimatorClass.UnloadAnimation(self: Object, animationName: string)
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

function AnimatorClass.LoadAnimation(self: Object, animationName: string, animationID: string)
    local Animation = Instance.new("Animation")
    Animation.AnimationId = animationID

    local Track = self._Animator:LoadAnimation(Animation)

    self._Tracks[animationName] = Track
end

function AnimatorClass.PlayAnimation(self: Object, animationName: string, animationLayer: number)
    local OldTrack = self._ActiveLayers[animationLayer]

    if OldTrack then
        OldTrack:Stop()
    end

    local NewTrack = self._Tracks[animationName]
    NewTrack:Play()

    self._ActiveLayers[animationLayer] = NewTrack
end

function AnimatorClass.StopAnimation(self: Object, animationName: string, animationLayer: number)
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

return AnimatorClass :: Module
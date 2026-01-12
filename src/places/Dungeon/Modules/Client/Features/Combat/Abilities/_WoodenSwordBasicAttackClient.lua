--[=[
    @class WoodenSwordBasicAttackClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local SharedModule = require("WoodenSwordBasicAttackShared")
local CombatTypes = require("CombatTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WoodenSwordBasicAttackClient = {}
WoodenSwordBasicAttackClient.__index = WoodenSwordBasicAttackClient

-- [ Types ] --
type ClientAbilityData = CombatTypes.ClientAbilityData
type Activate_Context = {
    Mode: Mode,
    Attacker: Model
}
type Mode = CombatTypes.Mode
type AbilityObject = CombatTypes.ClientAbilityObject
type Config = {
    Range: number,
    MinDot: number,
    Animation: string,
    Name: string,
    Damage: number,
}
export type ObjectData = {
    _Config: Config,
    _Active: boolean,
}
export type Object = ObjectData & AbilityObject & {
}
export type Module = {
    __index: Module,
    new: (config: Config) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function WoodenSwordBasicAttackClient.new(config: Config): Object
    local self = setmetatable({} :: any, WoodenSwordBasicAttackClient) :: Object

    self._Config = config
    self._Active = false

    return self
end

function WoodenSwordBasicAttackClient.Activate(self: Object, context: Activate_Context): ClientAbilityData?
    if self._Active == true then
        return
    end

    self._Active = true

    local Humanoid = context.Attacker:FindFirstChildOfClass("Humanoid")
    if not Humanoid then
        self._Active = false
        return 
    end
    
    local Animator = Humanoid:FindFirstChildOfClass("Animator")
    if not Animator then
        self._Active = false
        return 
    end

    local Animation = Instance.new("Animation")
    Animation.AnimationId = self._Config.Animation

    local Track = Animator:LoadAnimation(Animation)
    Track:Play()


    if context.Mode == "Prediction" then
        local Hits = {}
        local HitDetected = false

        Track:GetMarkerReachedSignal("Hit"):Once(function()
            Hits = SharedModule:DetectHits({
                Attacker = context.Attacker,
                Config = self._Config,
            })
            HitDetected = true
        end)

        local Timeout = 2
        local StartTime = os.clock()

        while not HitDetected do
            if StartTime + Timeout < os.clock() then
                warn("Hit detection timeout - no 'Hit' marker in animation?")
                self._Active = false
                return
            end
            task.wait()
        end

        task.spawn(function()
            Track.Stopped:Wait()
            self._Active = false
        end)

        return { Hits = Hits }
    else
        task.spawn(function()
            Track.Stopped:Wait()
            self._Active = false
        end)

        return
    end
end

return WoodenSwordBasicAttackClient :: Module
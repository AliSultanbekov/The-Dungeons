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
type AbilityObject = CombatTypes.AbilityObject
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
    if not Humanoid then return end
    local Animator = Humanoid:FindFirstChildOfClass("Animator")
    if not Animator then return end

    local Animation = Instance.new("Animation")
    Animation.AnimationId = self._Config.Animation

    local Track = Animator:LoadAnimation(Animation)
    Track:Play()


    if context.Mode == "Prediction" then
        local Hits = {}

        Track:GetMarkerReachedSignal("Hit"):Connect(function()
            SharedModule:DetectHits({
                Attacker = context.Attacker,
                Config = self._Config,
                OnHit = function(hitCharacter)
                    table.insert(Hits, hitCharacter)
                end
            })
        end)

        Track.Stopped:Wait()
    
        if context.Mode == "Prediction" then
            SharedModule:Validate({
                Attacker = context.Attacker,
                Config = self._Config,
                Hits = Hits,
            })
        end

        Track.Ended:Wait()
        self._Active = false

        return { Hits = Hits }
    else
        Track.Ended:Wait()
        self._Active = false
        return nil
    end
end

return WoodenSwordBasicAttackClient :: Module
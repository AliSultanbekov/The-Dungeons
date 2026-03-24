--[=[
    @class AbilityEfectManager
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local VFXClass = require("VFXClass")
local VFXContainer = require("VFXContainer")
local SoundUtil = require("SoundUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AbilityEfectManager = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(AbilityEfectManager) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function AbilityEfectManager.CreateHitEffect(self: Module, character: Model, effectName: string)
    local PrimaryPart = character.PrimaryPart

    if not PrimaryPart then
        return
    end

    if effectName == "Hit" then
        local VFXObject = VFXClass.new(
            {"VFX/Hit"},
            VFXContainer:FromAttachment(PrimaryPart, CFrame.new()),
            {
                Cleanup = 3
            }
        )
        VFXObject:Emit()

        SoundUtil:PlaySound(string.format("Punches/Punch%d", math.random(1,5)))
    elseif effectName == "Block" then
        local VFXObject = VFXClass.new(
            {"VFX/Block"},
            VFXContainer:FromAttachment(PrimaryPart, CFrame.new()),
            {
                Cleanup = 3
            }
        )
        VFXObject:Emit()
        SoundUtil:PlaySound("Block")
    elseif effectName == "Parry" then
        local VFXObject = VFXClass.new(
            {"VFX/Parry"},
            VFXContainer:FromAttachment(PrimaryPart, CFrame.new()),
            {
                Cleanup = 3
            }
        )
        VFXObject:Emit()
        SoundUtil:PlaySound("Parry")
    elseif effectName == "Dodge" then
        local VFXObject = VFXClass.new(
            {"VFX/Dodge"},
            PrimaryPart,
            {
                Cleanup = 3
            }
        )
        VFXObject:Emit()
    end
end

return AbilityEfectManager :: Module
--[=[
    @class CharacterUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CharacterUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(CharacterUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CharacterUtil.SetBodyPartsMass(self: Module, character: Model, value: boolean)
    for _, instance in character:GetChildren() do
        if not instance:IsA("BasePart") or instance.Name == "HumanoidRootPart" then
            continue
        end

        instance.Massless = value
    end
end

return CharacterUtil :: Module
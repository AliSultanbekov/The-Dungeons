--[=[
    @class GetPartFromCharacter
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GetPartFromCharacter = {}

-- [ Types ] --
export type Module = typeof(GetPartFromCharacter)

-- [ Private Functions ] --

-- [ Public Functions ] --
function GetPartFromCharacter.GetPart(self: Module, player: Player, partName: string): (Instance?)
    local Character = player.Character

    if not Character then
        return nil
    end

    local Part = Character:FindFirstChild(partName) :: Instance?

    if not Part then
        return nil
    end

    return Part
end

return GetPartFromCharacter :: Module
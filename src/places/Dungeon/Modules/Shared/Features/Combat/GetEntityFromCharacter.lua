--[=[
    @class GetEntityFromCharact
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GetEntityFromCharact = function(character: Model)
    local Entity = character:GetAttribute("EntityID") :: Jecs.Entity
    
    if not Entity then
        error("[CombatEntityService] Entity not found on character")
    end

    return Entity
end

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(GetEntityFromCharact) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GetEntityFromCharact :: Module
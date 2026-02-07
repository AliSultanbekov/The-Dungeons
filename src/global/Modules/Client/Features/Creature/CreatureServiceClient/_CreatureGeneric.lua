--[=[
    @class CreatureGeneric
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../CreatureTypesClient")

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local AnimationClass = require("AnimationClass")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureGeneric = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))

type ModuleData = {
    _EntityServiceClient: EntityServiceClient
}

export type Module = typeof(CreatureGeneric) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureGeneric.GetAnimationObject(self: Module, entity: Jecs.Entity): AnimationClass.Object
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local AnimationObject = World:get(entity, Components.AnimationObject)

    if not AnimationObject then
        error(("[CreatureGeneric] No AnimationObject found for entity %s"):format(tostring(entity)))
    end

    return AnimationObject
end

function CreatureGeneric.Init(self: Module, context: Types.Init_Context)
    self._EntityServiceClient = context.EntityServiceClient
end

function CreatureGeneric.Start(self: Module)

end

return CreatureGeneric :: Module

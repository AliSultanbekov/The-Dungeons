--[=[
    @class CreatureGeneric
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../CreatureTypesClient")

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local AnimatorClass = require("AnimatorClass")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureGeneric = {}

-- [ Types ] --
type EntityServiceClient = typeof(require("EntityServiceClient"))

type ModuleData = {
    _EntityServiceClient: EntityServiceClient,
    _Animators: { [Model]: AnimatorClass.Object },
    _Signals: Types.PublicSignals
}

export type Module = typeof(CreatureGeneric) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureGeneric.SetBaseAnimations(self: Module, character: Model)
    
end

function CreatureGeneric.GetAnimationObject(self: Module, character: Model): AnimatorClass.Object
    return self._Animators[character]
end

function CreatureGeneric.Init(self: Module, context: Types.Init_Context)
    self._EntityServiceClient = context.EntityServiceClient
    self._Animators = {}
    self._Signals = context.Signals
end

function CreatureGeneric.Start(self: Module)
    self._Signals.CreatureCreated:Connect(function(packet: Types.CreatureCreatedSignalPacket)
        self._Animators[packet.Character] = AnimatorClass.new(packet.Character)
    end)
end

return CreatureGeneric :: Module

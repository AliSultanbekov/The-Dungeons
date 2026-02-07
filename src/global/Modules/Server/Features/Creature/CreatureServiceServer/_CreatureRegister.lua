--[=[
    @class CreatureRegister
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../CreatureTypesServer")

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureRegister = {}

-- [ Types ] --
type EntityServiceServer = typeof(require("EntityServiceServer"))

type ModuleData = {
    _EntityServiceServer: EntityServiceServer,
    _CharacterToEntity: { [Model]: Jecs.Entity },
    PublicSignals: Types.PublicSignals
}

export type Module = typeof(CreatureRegister) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureRegister.RegisterNPC(self: Module, character: Model)
    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Entity = self._EntityServiceServer:CreateEntity({
        Tags = {
            Creature = true,
            NPC = true
        },
        Components = {
            Name = character.Name,
            Health = 1000,
            Ether = 100,
            Character = {
                Character = character,
                Humanoid = Humanoid,
            },
            CurrentAbilities = {},
            PreviousAbilities = {},
            AbilityCooldowns = {}
        },
        Replicated = true
    })

    self._CharacterToEntity[character] = Entity

    self.PublicSignals.CreatureCreated:Fire(character)

    Humanoid.Died:Once(function()
        self._EntityServiceServer:DeleteEntity({ Entity = Entity, Replicated = true })
        self._CharacterToEntity[character] = nil
        self.PublicSignals.CreatureDeleted:Fire(character)
    end)
end

function CreatureRegister.RegisterPlayer(self: Module, character: Model)
    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Entity = self._EntityServiceServer:CreateEntity({
        Tags = {
            Creature = true,
            Player = true
        },
        Components = {
            Name = character.Name,
            Health = 1000,
            Ether = 100,
            Character = {
                Character = character,
                Humanoid = Humanoid,
            },
            CurrentAbilities = {},
            PreviousAbilities = {},
            AbilityCooldowns = {}
        },
        Replicated = true
    })

    self._CharacterToEntity[character] = Entity

    self.PublicSignals.CreatureCreated:Fire(character)
    
    Humanoid.Died:Once(function()
        self._EntityServiceServer:DeleteEntity({ Entity = Entity, Replicated = true })
        self._CharacterToEntity[character] = nil
        self.PublicSignals.CreatureDeleted:Fire(character)
    end)
end

function CreatureRegister.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CharacterToEntity[character]
end

function CreatureRegister.Init(self: Module, context: Types.Init_Context)
    self._EntityServiceServer = context.EntityServiceServer
    self._CharacterToEntity = {}
    self.PublicSignals = context.PublicSignals
end

function CreatureRegister.Start(self: Module)
    
end

return CreatureRegister :: Module
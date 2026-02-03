--[=[
    @class CreatureRegister
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

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
    _CharacterToEntity: { [Model]: Jecs.Entity }
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
            "Alive",
            "NPC"
        },
        Components = {
            Name = character.Name,
            Health = 1000,
            Ether = 100,
            Character = {
                Character = character,
                Humanoid = Humanoid,
            },
            AbilityCooldowns = {}
        },
        Replicated = true
    })

    self._CharacterToEntity[character] = Entity

    character.Destroying:Once(function()  
        self._EntityServiceServer:DeleteEntity({ Entity = Entity, Replicated = true })
        self._CharacterToEntity[character] = nil
    end)
end

function CreatureRegister.RegisterPlayer(self: Module, character: Model)
    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Entity = self._EntityServiceServer:CreateEntity({
        Tags = {
            "Alive",
            "Player"
        },
        Components = {
            Name = character.Name,
            Health = 1000,
            Ether = 100,
            Character = {
                Character = character,
                Humanoid = Humanoid,
            },
            AbilityCooldowns = {}
        },
        Replicated = true
    })

    self._CharacterToEntity[character] = Entity

    character.Destroying:Once(function()  
        self._EntityServiceServer:DeleteEntity({ Entity = Entity, Replicated = true })
        self._CharacterToEntity[character] = nil
    end)
end

function CreatureRegister.GetEntityFromCharacter(self: Module, character: Model): Jecs.Entity
    return self._CharacterToEntity[character]
end

function CreatureRegister.Init(self: Module, entityServiceServer: EntityServiceServer)
    self._EntityServiceServer = entityServiceServer
    self._CharacterToEntity = {}
end

function CreatureRegister.Start(self: Module)
    
end

return CreatureRegister :: Module
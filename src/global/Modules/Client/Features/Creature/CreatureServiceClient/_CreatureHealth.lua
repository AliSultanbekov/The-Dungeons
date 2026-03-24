--[=[
    @class CreatureHealth
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local Types = require("../CreatureTypesClient")

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local Jecs = require("Jecs")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CreatureHealth = {}

-- [ Types ] --
type CreatureHealthChangedSignalPacket = {
    Character: Model,
    NewHealth: number,
}

type EntityServiceClient = typeof(require("EntityServiceClient"))

type ModuleData = {
    _EntityServiceClient: EntityServiceClient,
    _CreatureHealthChanged: Signal.Signal<CreatureHealthChangedSignalPacket>
}

export type Module = typeof(CreatureHealth) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function CreatureHealth.ObserveCreatureHealth(self: Module, entity: Jecs.Entity, cb: (newHealth: number) -> ()): Signal.Connection<any>
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local Health = World:get(entity, Components.Health)

    if not Health then
        error("Health component not found for given entity")
    end

    cb(Health)

    return self._CreatureHealthChanged:Connect(function(packet: CreatureHealthChangedSignalPacket)
        cb(packet.NewHealth)
    end)
end

function CreatureHealth.GetCreatureHealth(self: Module, entity: Jecs.Entity): number
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    local Health = World:get(entity, Components.Health)

    if not Health then
        error("Health component not found for given entity")
    end

    return Health
end

function CreatureHealth.Init(self: Module, context: Types.Init_Context)
    self._EntityServiceClient = context.EntityServiceClient
    self._CreatureHealthChanged = Signal.new() :: any
end

function CreatureHealth.Start(self: Module)
    local World = self._EntityServiceClient:GetWorld()
    local Components = self._EntityServiceClient:GetComponents()

    self._CreatureHealthChanged:Connect(function(packet: CreatureHealthChangedSignalPacket)
        World:changed(Components.Health, function(entity: Jecs.Entity, id, value: number)
            local Character = World:get(entity, Components.Character)

            if not Character then
                return
            end

            self._CreatureHealthChanged:Fire({
                Character = Character.Character,
                NewHealth = value
            })
        end)
    end)
end

return CreatureHealth :: Module

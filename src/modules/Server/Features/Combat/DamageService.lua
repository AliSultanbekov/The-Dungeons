--[=[
    @class DamageService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DamageService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkService: typeof(require("NetworkService"))
}

export type Module = typeof(DamageService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function DamageService.Damage(self: Module, character: Model, amount: number)
    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    if Humanoid.Health <= 0 then
        return
    end
    
    Humanoid.Health = math.max(0, Humanoid.Health - amount)
end

function DamageService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkService = self._ServiceBag:GetService(require("NetworkService"))
end

function DamageService.Start(self: Module)
    local Network = self._NetworkService:GetNetwork("DamageService")

    Network:DeclareEvent("Damage")

    Network:Connect("Damage", function(player: Player, character: Model, amount: number)
        self:Damage(character, amount)
    end)
end

return DamageService :: Module
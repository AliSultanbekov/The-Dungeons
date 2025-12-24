--[=[
    @class WeaponController
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local WeaponConfig = require("WeaponConfig")
local AssetProvider = require("AssetProvider")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local WeaponController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceClient: typeof(require("NetworkServiceClient")),
    _HitboxServiceClient: typeof(require("HitboxServiceClient"))
}

export type Module = typeof(WeaponController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeaponController.Attack(self: Module, weaponName: string)
    local Network = self._NetworkServiceClient:GetNetwork("DamageService")

    local Character = Player.Character

    if not Character then 
        return
    end

    self._HitboxServiceClient:Create({
        HitboxType = "Box",
        CFrame = CFrame.lookAlong(Character:GetPivot().Position, Character:GetPivot().LookVector * Vector3.new(1, 0, 1)):ToWorldSpace(CFrame.new(0, 0, -5/2)),
        Size = Vector3.new(5,5,5),
        Ignore = { Player.Character },
        Cb = function(enemy)
            Network:FireServer("Damage", enemy, 10)
        end,
        Visualise = false,
    })

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    
    if not Humanoid then
        return
    end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")

    if not Animator then
        return
    end

    --local Track = Animator:LoadAnimation(AssetProvider:Get({"Animations", "Swing"}))
    --Track:Play()
end

function WeaponController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceClient = self._ServiceBag:GetService(require("NetworkServiceClient"))
    self._HitboxServiceClient = self._ServiceBag:GetService(require("HitboxServiceClient"))
end

function WeaponController.Start(self: Module)
end

return WeaponController :: Module
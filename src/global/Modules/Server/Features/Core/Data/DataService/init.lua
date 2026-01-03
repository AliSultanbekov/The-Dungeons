--[=[
    @class DataService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local ProfileStore = require("@self/_ProfileStore")
local ProfileConfig = require("@self/_ProfileConfig")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --
local KEY = "V_2"
local PROFILE_TEMPLATE = ProfileConfig.Template

-- [ Module Table ] --
local DataService = {}

-- [ Types ] --
type Profile = ProfileStore.Profile<ProfileConfig.ProfileTemplate>

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PlayerService: typeof(require("PlayerService")),
    _Profiles: { [Player]: Profile },
    _PlayerStore: ProfileStore.ProfileStore<ProfileConfig.ProfileTemplate>
}

export type Module = typeof(DataService) & ModuleData

-- [ Private Functions ] --
function ProcessPath(initialSegment: any, path: string, hardSet: boolean?): (boolean, any, any, any)
    local CurrentSegment = initialSegment
    local ParentSegment
    local LastSegment

    for _, segment in path:split("/") do
        if CurrentSegment[segment] ~= nil then
            ParentSegment = CurrentSegment
            LastSegment = segment
            CurrentSegment = CurrentSegment[segment]
        elseif hardSet then
            CurrentSegment[segment] = {}
            ParentSegment = CurrentSegment
            LastSegment = segment
            CurrentSegment = CurrentSegment[segment]
        else
            return false
        end
    end

    return true, CurrentSegment, ParentSegment, LastSegment
end

function DataService._SetupPlayerProfile(self: Module, player: Player)
    local Profile = self._PlayerStore:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })

    if Profile then
        Profile:AddUserId(player.UserId)
        Profile:Reconcile()

        Profile.OnSessionEnd:Connect(function()
            self._Profiles[player] = nil
            player:Kick("Profile seasion end - Please rejoin")
        end)

        if player.Parent == Players then
            self._Profiles[player] = Profile
            print(`Profile loaded for {player.DisplayName}!`)
        else
            Profile:EndSession()
        end
    else
        player:Kick(`Profile load fail - Please rejoin`)
    end
end

-- [ Public Functions ] --
function DataService.AddData(self: Module, player: Player, value: number, path: string): boolean
    if type(value) == "number" and (value ~= value) then
        warn("Invalid numeric value provided. Expected a number.")
        return false
    end

    local Success1, Result1 = self:GetData(player, path)

    if not Success1 then
        return false
    end

    if type(Result1) ~= "number" then
        return false
    end

    local Success2 = self:SetData(player, value + Result1, path)

    if not Success2 then
        return false
    end

    return true
end

function DataService.SetData(self: Module, player: Player, value: any, path: string, hardSet: boolean?): boolean
    if type(value) == "number" and (value ~= value) then
        warn("Invalid numeric value provided. Expected a number.")
        return false
    end

    if typeof(value) == "number" and value < 0 then
        warn("Attempted to set a negative value in DataService.SetData. Player:", player, "Path:", path, "Value:", value)
        return false
    end

    local Profile = self:GetProfile(player)

    local Success, _, ParentSegment, LastSegment = ProcessPath(Profile.Data, path, hardSet)

    if not Success then
        return false
    end

    ParentSegment[LastSegment] = value

    return true
end

function DataService.UpdateData(self: Module, player: Player, cb: (data: ProfileConfig.ProfileTemplate) -> ()): boolean
    local Profile = self:GetProfile(player)

    local Success, _ = pcall(function(...)
        cb(Profile.Data)
    end)

    if not Success then
        return false
    end

    return true
end

function DataService.GetData(self: Module, player: Player, path: string): (boolean, any)
    local Profile = self:GetProfile(player)
    
    local Success, CurrentSegment = ProcessPath(Profile.Data, path)

    if not Success then
        return false
    end

    return true, CurrentSegment
end

function DataService.GetProfile(self: Module, player: Player): Profile
    local Deadline = os.clock() + 5

    while self._Profiles[player] == nil and os.clock() < Deadline do
        task.wait(0.05)
    end

    local Profile = self._Profiles[player]

    if not Profile then
        error(("[DataService] Profile not ready for %s"):format(player.Name))
    end

    return Profile
end

function DataService.OnPlayerAdded(self: Module, Maid: Maid.Maid, player: Player)
    self:_SetupPlayerProfile(player)
end

function DataService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PlayerService = self._ServiceBag:GetService(require("PlayerService"))

    self._Profiles = {}
end

function DataService.Start(self: Module)
    self._PlayerService:RegisterService(self)

    self._PlayerStore = ProfileStore.New(KEY, PROFILE_TEMPLATE)
end

return DataService :: Module
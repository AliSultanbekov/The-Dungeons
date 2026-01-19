--[=[
    @class NotificationService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ChoiceNotificationClass = require("./NotificationClass/_ChoiceNotificationClass")
local Types = require("./_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NotificationService = {}

-- [ Types ] --
type Info = Types.ChoiceNotificationInfo
type ChoiceNotificationInfo = Types.ChoiceNotificationInfo
type NotificationType = "ChoiceNotification" | "GenericNotification"
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _ChoiceNotification: ChoiceNotificationClass.Object?,
}

export type Module = typeof(NotificationService) & ModuleData

-- [ Private Functions ] --
function NotificationService._CreateChoiceNotification(self: Module, info: Info)
    self._Maid:DoCleaning()

    local ChoiceNotification = ChoiceNotificationClass.new(info)

    self._Maid:Add(ChoiceNotification.InteractionSignal:Connect(function()
            self._Maid:DoCleaning()
    end))

    self._Maid:Add(function()
        ChoiceNotification:Destroy()
        self._ChoiceNotification = nil
    end)

    self._ChoiceNotification = ChoiceNotification
end

-- [ Public Functions ] --
function NotificationService.Notify(self: Module, notificationType: string, info: ChoiceNotificationInfo)
    if notificationType == "ChoiceNotification" then
        self:_CreateChoiceNotification(info)
    end
end

function NotificationService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._ChoiceNotification = nil
end

function NotificationService.Start(self: Module)
    
end

return NotificationService :: Module
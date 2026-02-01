--[=[
    @class UserInputManager
]=]

-- [ Roblox Services ] --
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Require ] --
local rbxrequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Rx = require("Rx")
local InputKeyMapList = require("InputKeyMapList")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UserInputManager = {}

-- [ Types ] --
type KeymapActionPacket = {
    InputObject: InputObject,
    InputState: Enum.UserInputState,
    ActionName: string
}

type ActionCacheData = {
    Maid: Maid.Maid,
    Priority: number,
    Cb: (KeymapActionPacket) -> (),
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Controls: any,
    _Maid: Maid.Maid,
    _Actions: { [string]: ActionCacheData }
}

export type Module = typeof(UserInputManager) & ModuleData

-- [ Private Functions ] --
local function _CheckAction(self: Module, actionName: string)
    if self._Actions[actionName] then
        error(string.format("[UserInputManager] Action with name '%s' already exists!", actionName))
    end
end
-- [ Public Functions ] --
function UserInputManager.ToggleControls(self: Module, toggle: boolean)
    if toggle == true then
        self._Controls:Enable()
    elseif toggle == false then
        self._Controls:Disable()
    end
end

function UserInputManager.RegisterKeymapAction(
    self: Module, 
    actionName: string, 
    keyMapList: InputKeyMapList.InputKeyMapList, 
    cb: (KeymapActionPacket) -> (),
    priority: number?
)
    _CheckAction(self, actionName)

    local ActionMaidObj = Maid.new()
    local Priority = priority or Enum.ContextActionPriority.Medium.Value

    ActionMaidObj:GiveTask(
        Rx.combineLatest({
            IsTouchButton = keyMapList:ObserveIsRobloxTouchButton(),
            InputEnumsList = keyMapList:ObserveInputEnumsList()
        }):Subscribe(function(data)
            ContextActionService:BindActionAtPriority(
                actionName,
                function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
                    cb({InputObject = inputObject, InputState = inputState, ActionName = actionName})
                end,
                data.IsTouchButton,
                Priority,
                table.unpack(data.InputEnumsList)
            )
        end)
    )

    ActionMaidObj:GiveTask(function()
        ContextActionService:UnbindAction(actionName)
    end)

    self._Actions[actionName] = {
        Maid = ActionMaidObj,
        Priority = Priority,
        Cb = cb
    }

    self._Maid:GiveTask(ActionMaidObj)

    return function()
        local Data = self._Actions[actionName]

        if not Data then
            return
        end

        Data.Maid:DoCleaning()
        self._Actions[actionName] = nil
    end
end

function UserInputManager.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._Maid = Maid.new()

    self._Actions = {}
end

function UserInputManager.Start(self: Module)
    task.spawn(function()
        self._Controls = rbxrequire(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
    end)
end

return UserInputManager :: Module
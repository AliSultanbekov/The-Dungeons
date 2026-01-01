--[=[
    @class UIGridClass
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] --
local ObjectPool = require("ObjectPool")
local AssetProvider = require("AssetProvider")

-- [ Constants ] --
local DEFAULT_COMPARATOR = function(a: ElementUI, b: ElementUI): boolean
    return true
end

local BATCH_DEBOUNCE_TIME = 0.1
local BATCH_MAX_PEND_TIME = 0.5

-- [ Variables ] --
local UIPool = ObjectPool.new() :: ObjectPool.Object<GuiObject>
UIPool:AddKey(
    "BackingUI", 
    function()
        return AssetProvider:Get("UIs/Inventory/BackingUI")
    end,
    function(obj: any)
        obj.Parent = nil
    end
)
UIPool:ForceConstruct("BackingUI", 5)

-- [ Module Table ] --
local UIGridClass = {}
UIGridClass.__index = UIGridClass

-- [ Types ] --
type ElementUI = GuiObject
type BackingUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.BackingUI)
type Comparator = (a: ElementUI, b: ElementUI) -> boolean

export type ObjectData = {
    _ScrollingFrame: ScrollingFrame,
    _ElementUIToKey: { [ElementUI]: number },
    _ElementUIs: { ElementUI },
    _BackingUIs: { BackingUI },
    _Comparator: Comparator,

    _BatchData: {
        Active: boolean,
        PendingSince: number?,
        PendingThread: thread?,
    }
}
export type Object = ObjectData & Module
export type Module = typeof(UIGridClass)

-- [ Private Functions ] --
function UIGridClass._GetBackingCount(self: Object)
    return #self._BackingUIs
end

function UIGridClass._AddBacking(self: Object)
    local BackingUI = UIPool:Get("BackingUI") :: BackingUI
    BackingUI.Parent = self._ScrollingFrame
    BackingUI.LayoutOrder = self:_GetBackingCount()
    print(self._ScrollingFrame)

    table.insert(self._BackingUIs, BackingUI)
end

function UIGridClass._RemoveBacking(self: Object)
    local Index = self:_GetBackingCount()
    local BackingUI = self._BackingUIs[Index]
    UIPool:Return("BackingUI", BackingUI)

    table.remove(self._BackingUIs)
end

function UIGridClass.GetBackingUI(self: Object, order: number)
    return self._BackingUIs[order]
end

function UIGridClass._Sort(self: Object)
    table.sort(self._ElementUIs, self._Comparator)

    self._ElementUIToKey = {}

    for k, v in self._ElementUIs do
        self._ElementUIToKey[v] = k
        v.Parent = self:GetBackingUI(k)
    end
end

-- [ Public Functions ] --
function UIGridClass.new(scrollingFrame: ScrollingFrame, Comparator: Comparator?): Object
    local self = setmetatable({} :: any, UIGridClass) :: Object

    self._ScrollingFrame = scrollingFrame
    self._ElementUIs = {}
    self._ElementUIToKey = {}
    self._BackingUIs = {}
    self._Comparator = Comparator or DEFAULT_COMPARATOR

    self._BatchData = {
        Active = false,
        PendingSince = nil,
        PendingThread = nil,
    }

    return self
end

function UIGridClass.BatchSort(self: Object)
    local BatchData = self._BatchData

    local function execute()
        BatchData.Active = false
        BatchData.PendingSince = nil
        BatchData.PendingThread = nil

        self:_Sort()
    end

    local function createThread(): thread
        local Thread = task.delay(BATCH_DEBOUNCE_TIME, function()
            execute()
        end)

        return Thread
    end

    if not BatchData.Active or not BatchData.PendingSince or not BatchData.PendingThread then
        BatchData.Active = true
        BatchData.PendingSince = os.clock()
    else
        task.cancel(BatchData.PendingThread)

        if BatchData.PendingSince < os.clock() - BATCH_MAX_PEND_TIME then
            execute()
            return
        end
    end

    BatchData.PendingThread = createThread()
end

function UIGridClass.AddElement(self: Object, elementUI: ElementUI)
    table.insert(self._ElementUIs, elementUI)

    self:_AddBacking()

    self:BatchSort()
end

function UIGridClass.RemoveElement(self: Object, elementUI: ElementUI)
    local Index = self._ElementUIToKey[elementUI]
    self._ElementUIToKey[elementUI] = nil
    table.remove(self._ElementUIs, Index)

    self:_RemoveBacking()

    self:BatchSort()
end

return UIGridClass :: Module
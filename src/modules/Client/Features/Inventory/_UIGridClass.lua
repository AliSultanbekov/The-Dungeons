--[=[
    @class UIGridClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local SectionUIFactory = require("./Factories/_SectionUIFactory")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ObjectPool = require("ObjectPool")
local AssetProvider = require("AssetProvider")

-- [ Constants ] --

-- [ Variables ] --
local UIPool = ObjectPool.new() :: ObjectPool.Object<GuiObject>
UIPool:AddKey(
    "SectionUI", 
    function()
        return AssetProvider:Get("UIs/Inventory/SectionUI")
    end,
    function(obj: any)
        obj.Parent = nil
    end
)
UIPool:ForceConstruct("SectionUI", 5)

UIPool:AddKey(
    "BackingUI", 
    function()
        return AssetProvider:Get("UIs/Inventory/BackingUI")
    end,
    function(obj: any)
        obj.Parent = nil
    end
)
UIPool:ForceConstruct("SectionUI", 5)

-- [ Module Table ] --
local UIGridClass = {}
UIGridClass.__index = UIGridClass

-- [ Types ] --
type ElementUI = GuiObject
type BackingUI = GuiObject
type SectionUI = GuiObject

export type SectionsData = {
    [string]: {
        SectionUI: {
            Instance: SectionUI,
            Refs: SectionUIFactory.Refs
        },
        ElementCount: number,
        --ElementUIs: { ElementUI },
        BackingUIs: { [ElementUI]: BackingUI },
    }
}

export type ObjectData = {
    _ScrollingFrame: ScrollingFrame,
    _SectionsData: SectionsData,
    _SortedSections: { string },
}
export type Object = ObjectData & Module
export type Module = typeof(UIGridClass)

-- [ Private Functions ] --
function _UpdateTitleVisibility(self: Object, sectionName: string)
    local SectionData = self._SectionsData[sectionName]

    if not SectionData then
        return
    end

    local SectionUIRefs = SectionData.SectionUI.Refs

    if SectionData.ElementCount == 0 then
        SectionUIRefs.Title.Visible = false
    else
        SectionUIRefs.Title.Visible = true
    end
end

-- [ Public Functions ] --
function UIGridClass.new(scrollingFrame: ScrollingFrame): Object
    local self = setmetatable({} :: any, UIGridClass) :: Object

    self._ScrollingFrame = scrollingFrame
    self._SectionsData = {}
    self._SortedSections = {}
    
    return self
end

function UIGridClass.CreateSection(self: Object, sectionName: string)
    if self._SectionsData[sectionName] then
        return
    end

    local SectionUI = UIPool:Get("SectionUI")

    SectionUI.Parent = self._ScrollingFrame

    local SectionData = {
        SectionUI = {
            Instance = SectionUI,
            Refs = SectionUIFactory:ProduceRefs(SectionUI)
        },
        ElementCount = 0,
        BackingUIs = {},
    }

    self._SectionsData[sectionName] = SectionData

    table.insert(self._SortedSections, sectionName)

    _UpdateTitleVisibility(self, sectionName)
end

function UIGridClass.AddElement(self: Object, sectionName: string, elementUI: ElementUI)
    local SectionData = self._SectionsData[sectionName]

    if not SectionData then
        warn(("[UIGridClass.AddElement] Tried to add element to missing section '%s'"):format(sectionName))
        return
    end

    local BackingUI = UIPool:Get("BackingUI")
    BackingUI.Parent = SectionData.SectionUI.Refs.Elements
    elementUI.Parent = BackingUI
    
    SectionData.BackingUIs[elementUI] = BackingUI
    SectionData.ElementCount += 1

    _UpdateTitleVisibility(self, sectionName)
end

function UIGridClass.RemoveElement(self: Object, sectionName: string, elementUI: ElementUI)
    local SectionData = self._SectionsData[sectionName]

    if not SectionData then
        warn(("[UIGridClass.RemoveElement] Tried to remove element from missing section '%s'"):format(sectionName))
        return
    end

    local BackingUI = SectionData.BackingUIs[elementUI]
    UIPool:Return("BackingUI", BackingUI)

    if SectionData.ElementCount ~= 0 then
        SectionData.ElementCount -= 1
    end

    _UpdateTitleVisibility(self, sectionName)
end

return UIGridClass :: Module
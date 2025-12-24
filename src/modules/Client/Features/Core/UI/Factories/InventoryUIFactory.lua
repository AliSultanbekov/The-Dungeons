--[=[
    @class InventoryFactory
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryFactory = {
    UIName = "InventoryUI",
    Cache = {}
}

-- [ Types ] --
export type Refs = {
	InventoryUI: Frame,
	Close: ImageButton,
	Tabs: Folder,
	Title: ImageLabel,
	UIScale: UIScale,
}

export type Module = typeof(InventoryFactory)

-- [ Private Functions ] --
local function Must(parent: Instance, name: string, class: string?): Instance
    local Inst = parent:FindFirstChild(name)
    assert(Inst, ("Missing %s under %s"):format(name, parent:GetFullName()))
    if class then
        assert(Inst:IsA(class), ("%s must be %s, got %s"):format(name, class, Inst.ClassName))
    end
    return Inst
end

-- [ Public Functions ] --
function InventoryFactory.ProduceRefs(self: Module, screenGuis: { [string]: ScreenGui })
    if next(self.Cache) ~= nil then
        return self.Cache :: Refs
    end

    local InventoryUI = Must(screenGuis["Main"], "InventoryUI", "Frame") :: Frame
    local Close = Must(InventoryUI, "Close", "ImageButton") :: ImageButton
    local Tabs = Must(InventoryUI, "Tabs", "Folder") :: Folder
    local Title = Must(InventoryUI, "Title", "ImageLabel") :: ImageLabel
    local UIScale = Must(InventoryUI, "UIScale", "UIScale") :: UIScale

    local Refs: Refs = {
        InventoryUI = InventoryUI,
        Close = Close,
        Tabs = Tabs,
        Title = Title,
        UIScale = UIScale,
    }

    self.Cache = Refs

    return Refs
end

return InventoryFactory :: Module
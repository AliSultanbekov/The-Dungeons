--[=[
    @class ItemUIFactory
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemUIFactory = {}

-- [ Types ] --
export type Refs = {
	Corners: ImageLabel,
	Image: ImageLabel,
	Inner: ImageLabel,
	Name: TextLabel,
	Outline: ImageLabel,
	Color: UIGradient,
	TextLabel: TextLabel,
}

export type Module = typeof(ItemUIFactory)

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
function ItemUIFactory.ProduceRefs(self: Module, instance: GuiButton)

    local Corners = Must(instance, "Corners", "ImageLabel") :: ImageLabel
    local Image = Must(instance, "Image", "ImageLabel") :: ImageLabel
    local Inner = Must(instance, "Inner", "ImageLabel") :: ImageLabel
    local Name = Must(instance, "Name", "TextLabel") :: TextLabel
    local Outline = Must(instance, "Outline", "ImageLabel") :: ImageLabel
    local Color = Must(Inner, "Color", "UIGradient") :: UIGradient
    local TextLabel = Must(Name, "TextLabel", "TextLabel") :: TextLabel

    local Refs: Refs = {
        Corners = Corners,
        Image = Image,
        Inner = Inner,
        Name = Name,
        Outline = Outline,
        Color = Color,
        TextLabel = TextLabel,
    }

    return Refs
end

return ItemUIFactory :: Module
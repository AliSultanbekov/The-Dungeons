--[=[
    @class SectionUIFactory
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local SectionUIFactory = {}

-- [ Types ] --
export type Refs = {
	Elements: Frame,
	Title: TextLabel,
	TextLabel: TextLabel,
}

export type Module = typeof(SectionUIFactory)

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
function SectionUIFactory.ProduceRefs(self: Module, instance: GuiObject)
    local Elements = Must(instance, "Elements", "Frame") :: Frame
    local Title = Must(instance, "Title", "TextLabel") :: TextLabel
    local TextLabel = Must(Title, "TextLabel", "TextLabel") :: TextLabel


    local Refs: Refs = {
        Elements = Elements,
        Title = Title,
        TextLabel = TextLabel,
    }

    return Refs
end

return SectionUIFactory :: Module
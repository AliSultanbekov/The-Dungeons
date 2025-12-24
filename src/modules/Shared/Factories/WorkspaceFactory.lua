--[=[
    @class NameFactory
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NameFactory = {
    Name = "Name",
    Cache = {}
}

-- [ Types ] --
export type Refs = {
    Game: Folder,
    Sounds: Folder,
}

export type Module = typeof(NameFactory)

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
function NameFactory.ProduceRefs(self: Module)
    if next(self.Cache) ~= nil then
        return self.Cache :: Refs
    end

    local Game = Must(workspace, "World", "Folder") :: Folder
    local Sounds = Must(Game, "Sounds", "Folder") :: Folder

    local Refs: Refs = {
        Game = Game,
        Sounds = Sounds,
    }

    self.Cache = Refs

    return Refs
end

return NameFactory :: Module
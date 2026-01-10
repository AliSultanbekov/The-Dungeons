--[=[
    @class WoodenSwordBasicAttackShared
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local _WeaponConfig = require("WeaponConfig")
local HitboxClass = require("HitboxClass")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WoodenSwordBasicAttackShared = {}

-- [ Types ] --
export type Module = typeof(WoodenSwordBasicAttackShared)

-- [ Private Functions ] --

-- [ Public Functions ] --
function WoodenSwordBasicAttackShared.DetectHits(self: Module, attacker: Model)
    local Hits = {}

    local HitboxObject = HitboxClass.new({
        HitboxClassType = "Box",
        CFrame = attacker:GetPivot(),
        Size = Vector3.new(5,5,5),
        Cb = function(hitCharacter: Model)
            table.insert(Hits, hitCharacter)
        end,
        RelativeTo = attacker:GetPivot():ToObjectSpace(attacker:GetPivot() * CFrame.new(0, 0, -3)),
        Ignore = { attacker },
        Visualise = true
    })

    HitboxObject:Trigger()

    return Hits
end

return WoodenSwordBasicAttackShared :: Module
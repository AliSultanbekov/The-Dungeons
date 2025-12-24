--[=[
    @class WeaponConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WeaponConfig = {
    ["Wooden Sword"] = {
        Combo = 3,
        Primary = {
            [1] = { Anim = "rbxassetid://...", Damage = 2, Recovery = 0.25 },
            [2] = { Anim = "rbxassetid://...", Damage = 2, Recovery = 0.25 },
            [3] = { Anim = "rbxassetid://...", Damage = 3, Recovery = 0.35 },
        }
    }
}

-- [ Types ] --
export type Module = typeof(WeaponConfig)

return WeaponConfig :: Module
--[=[
    @class ItemConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
---For primary stats, we have base multipliers that effect raw stats. So, if the player has 10 vitality, we multi that by 3 to get 30 raw stats.
local BasePrimaryStatsMultipliers = {
    Vitality = {
        Health = 50,
        HealthRegen = 5,
        PhysicalMitigation = 2,
        IncomingHealing = 2,
    },
    Strength = {
        PhysicalMastery = 5,
        PhysicalMitigation = 2,
        CriticalRating = 1.25,
        IncomingHealing = 2,
    },
    Dexterity = {
        CriticalRating = 1.5,
        ManaRegen = 2.5,
        HealthRegen = 2.5
    },
    Intelligence = {
        TacticalMastery = 5,
        ManaRegen = 5,
        CriticalRating = 1.25,
        OutgoingHealing = 2,
    },
    Focus = {
        CriticalRating = 5,
    },
}

-- [ Types ] --
export type Module = typeof(BasePrimaryStatsMultipliers)

return BasePrimaryStatsMultipliers :: Module
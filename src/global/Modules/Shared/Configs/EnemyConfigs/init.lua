--[=[
    @class SkillConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local StatTypes = require("StatsTypes")
local StatsCalculationUtility = require("StatsCalculationUtility")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ConfigsByEnemyName = {
    Basic = {
        Level = 1,
        EnemyType = "Normal",

        PrimaryStats = {
            Vitality = 5,
            Strength = 3,
            Dexterity = 2,
            Intelligence = 1,
            Focus = 5,
        },

        RawStats = {}
    },

    EliteEnemy = {
        Level = 5,
        EnemyType = "Elite",

        PrimaryStats = {
            Vitality = 15,
            Strength = 10,
            Dexterity = 8,
            Intelligence = 5,
            Focus = 12,
        },

        RawStats = {}
    },
}
-- [ Types ] --
export type Module = typeof(ConfigsByEnemyName)

for enemyName, config in ConfigsByEnemyName :: Module do
    StatsCalculationUtility:UpdateStats(config :: StatTypes.PlayerStats)

    table.freeze(config :: any)
end


return ConfigsByEnemyName :: Module
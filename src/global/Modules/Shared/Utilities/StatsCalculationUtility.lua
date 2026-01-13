--[=[
    @class StatsCalculationUtility
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local StatDefaults = require("StatDefaults")
local StatTypes = require("StatsTypes")
local GameConstants = require("GeneralGameConstants")
local BaseStatMultipliers = require("BasePrimaryStatsMultipliers")

type PlayerStats = StatTypes.PlayerStats
type StatConfig = StatTypes.StatConfig

-- [ Variables ] --
local Caps = StatDefaults

-- [ Module Table ] --
local StatsCalculationUtility = {}

-- [ Types ] --
export type Module = typeof(StatsCalculationUtility)

-- [ Private Functions ] --

local function CalcCap(level: number, statType: string): number
    local lStart = 1
    local lEnd = GameConstants.MAX_LEVEL
    
    local config = Caps[statType]
    if not config then
        warn("Invalid stat type:", statType)
        return 0
    end
    
    local b = (config.BStart * (lEnd - level) + (level - lStart) * config.BEnd) / (lEnd - lStart)
    local rCap = ((config.HardCap) / (config.SoftCap - config.HardCap)) * b
    local c = (config.HardCap) / (config.SoftCap - config.HardCap)
    local rOptimal = (math.sqrt(c + 1) - 1) / (c) * rCap

    return math.ceil(rOptimal)
end

-- [ Public Functions ] --

function StatsCalculationUtility.DamageReduction(self: Module, data : PlayerStats, playerLevel: number): number
    local maxReduction = .85
    local resistance = CalcCap(playerLevel, "PHYSICAL_MITIGATION")
    local reduction = data.RawStats.PhysicalMitigation / resistance < maxReduction and data.RawStats.PhysicalMitigation / resistance or maxReduction
    
    return reduction
end

function StatsCalculationUtility.CalcRegen(self: Module, data : PlayerStats, playerLevel : number): number
    local neededRegen = CalcCap(playerLevel, "HEALTH_REGEN")
    local maxRegen = .005
    local regen = data.RawStats.HealthRegen / neededRegen < maxRegen and data.RawStats.HealthRegen / neededRegen or maxRegen
    
    return regen
end

function StatsCalculationUtility.CalcCrit(self: Module, attackerData: PlayerStats, playerLevel: number, crit: number): (boolean, string?)
    local critChance = 0
    local critCap = .5
    local neededCritChance = CalcCap(playerLevel, "CRITICAL_RATING")
    
    if attackerData then
        critChance = attackerData.RawStats.CriticalRating / neededCritChance < critCap and attackerData.RawStats.CriticalRating / neededCritChance or critCap
    else
        critChance = crit / neededCritChance < critCap and crit / neededCritChance or critCap
    end	
    
    if math.random() <= critChance / 2 then
        return true, "Dev"
    elseif math.random() <= critChance then
        return true, "Normal"
    else
        return false
    end
end

function StatsCalculationUtility.CalcDamage(self: Module, casterLevel: number, data: PlayerStats, skillDamage: number): number
    local neededMastery = CalcCap(casterLevel, "PHYSICAL_MASTERY")
    local maxDamage = 2
    local multiplier = data.RawStats.PhysicalMastery / neededMastery * maxDamage < maxDamage and data.RawStats.PhysicalMastery / neededMastery * maxDamage or maxDamage
    local damageDelt = skillDamage * multiplier
    
    return math.ceil(damageDelt)
end

function StatsCalculationUtility.CalcHeal(self: Module, casterLevel: number, data: PlayerStats, healAmount: number): number
    local neededMastery = CalcCap(casterLevel, "OUTGOING_HEALING")
    local maxHeal = 2
    local multiplier = data.RawStats.OutgoingHealing / neededMastery * maxHeal < maxHeal and data.RawStats.OutgoingHealing / neededMastery * maxHeal or maxHeal
    local damageDelt = healAmount * multiplier
    
    return math.ceil(damageDelt)
end

function StatsCalculationUtility.CalcTacticalDamage(self: Module, casterLevel: number, data: PlayerStats, skillDamage: number): number
    local neededMastery = CalcCap(casterLevel, "TACTICAL_MASTERY")
    local maxDamage = 2
    local multiplier = data.RawStats.TacticalMastery / neededMastery * maxDamage < maxDamage and data.RawStats.TacticalMastery / neededMastery * maxDamage or maxDamage
    local damageDelt = multiplier * skillDamage
    
    return math.ceil(damageDelt)
end

function StatsCalculationUtility.TacticalDamageReduction(self: Module, data : PlayerStats, playerLevel: number): number
    local maxReduction = .85
    local resistance = CalcCap(playerLevel, "TACTICAL_MITIGATION")
    local reduction = data.RawStats.TacticalMitigation / resistance < maxReduction and data.RawStats.TacticalMitigation / resistance or maxReduction
    
    return reduction
end

function StatsCalculationUtility.CalcManaRegen(self: Module, data : PlayerStats, playerLevel : number): number
    local neededRegen = CalcCap(playerLevel, "MANA_REGEN")
    local maxRegen = .5
    local regen = data.RawStats.ManaRegen / neededRegen < maxRegen and data.RawStats.ManaRegen / neededRegen or maxRegen
    
    return regen
end

function StatsCalculationUtility.CalcIncomingHealing(self: Module, data : PlayerStats, playerLevel: number): number
    local neededStat = CalcCap(playerLevel, "INCOMING_HEALING")
    local maxBonus = 2
    local multiplier = data.RawStats.IncomingHealing / neededStat * maxBonus < maxBonus and data.RawStats.IncomingHealing / neededStat * maxBonus or maxBonus
    
    return 1 + multiplier
end

function StatsCalculationUtility.UpdateStats(self: Module, data : PlayerStats): number
    local primaryStats = data.PrimaryStats

    for key, value in next, BaseStatMultipliers do 
        local statValue = primaryStats[key]

        for rawStatKey, rawStatMultiplier in next, value do
            if not data.RawStats[rawStatKey] then 
                data.RawStats[rawStatKey] = 0
            end

            data.RawStats[rawStatKey] = data.RawStats[rawStatKey] + (statValue * rawStatMultiplier)
        end
    end

    return 0
end

return StatsCalculationUtility :: Module
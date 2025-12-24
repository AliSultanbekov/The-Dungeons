--[=[
    @class ChanceClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local LUCK_AFFECTED = 5

-- [ Variables ] --

-- [ Module Table ] --
local ChanceClass = {}
ChanceClass.__index = ChanceClass

-- [ Types ] --
export type ChanceMap = {
    [string]: number,
}

export type WeightMap = {
    [string]: number,
}

export type ObjectData = {
    _Luck: number,
    _TotalWeight: number,

    _InitialChanceMap: ChanceMap,
    _ChanceMap: ChanceMap,
    _WeightMap: WeightMap,
}
export type Object = ObjectData & Module
export type Module = typeof(ChanceClass)

-- [ Private Functions ] --
function _ProcessChances(self: Object)
    local Luck = self._Luck

    local TotalChance = 0
    local TotalChance_NonLuckAffected = 0
    local ProcessedChances = {}
    local NonLuckAffected = {}

    for key, chance in self._InitialChanceMap do
        if chance <= LUCK_AFFECTED then
            chance = chance * Luck
            ProcessedChances[key] = chance
        else
            TotalChance_NonLuckAffected += chance
            NonLuckAffected[key] = chance
        end

        TotalChance += chance
    end

    local Remainder = math.abs(TotalChance - 100)

    for key, chance in NonLuckAffected do
        local NormalisedChance = chance / TotalChance_NonLuckAffected
        local NewChance = chance + math.floor((NormalisedChance * Remainder)*100)/100
        ProcessedChances[key] = NewChance
    end

    self._ChanceMap = ProcessedChances
end

function _ProcessWeights(self: Object)
    local function GetDecimalCount(num: number): number
        local s = tostring(num)
        local dotIndex = string.find(s, "%.")
        if not dotIndex then return 0 end
        return #s - dotIndex
    end

    local Decimals = 0
    local TotalWeight = 0
    local ProcessedWeights = {}

    for key, chance in self._ChanceMap do
        local NewDecimal = GetDecimalCount(chance)

        if NewDecimal > Decimals then
            Decimals = NewDecimal
        end
    end

    for key, chance in self._ChanceMap do
        local NewWeight = chance * math.pow(10, Decimals)
        ProcessedWeights[key] = NewWeight
        TotalWeight += NewWeight
    end

    self._TotalWeight = TotalWeight
    self._WeightMap = ProcessedWeights
end

-- [ Public Functions ] --
function ChanceClass.new(chanceMap: ChanceMap): Object
    local self = setmetatable({} :: any, ChanceClass) :: Object

    self._Luck = 1
    self._TotalWeight = 0

    self._InitialChanceMap = chanceMap
    self._ChanceMap = {}
    self._WeightMap = {}

    _ProcessChances(self)
    _ProcessWeights(self)

    return self
end

function ChanceClass.Choose(self: Object): string
    local Random = math.random(1, self._TotalWeight)
    local Progress = 0

    for key, weight in self._WeightMap do
        Progress += weight
        if Random <= Progress then
            return key
        end
    end

    error("Issue when choosing a random")
end

function ChanceClass.GetInitialChance(self: Object, key: string)
    return self._ChanceMap[key]
end

return ChanceClass :: Module
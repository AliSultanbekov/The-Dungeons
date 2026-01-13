--[=[
    @class StatDefaults
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

local gameConstants = require("GeneralGameConstants")

-- [ Imports ] --

-- [ Constants ] --
local LEVEL_SEGMENT = gameConstants.MAX_LEVEL -- gameConstants.MAX_LEVEL
-- [ Variables ] --

-- [ Module Table ] --`
local StatDefaults = {
    TACTICAL_MASTERY = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = 200;
        SoftCap = 300;
        BStart = 50;
        BEnd = 76 * LEVEL_SEGMENT;	
    },
    PHYSICAL_MASTERY = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = 200;
        SoftCap = 300;
        BStart = 50;
        BEnd = 76 * LEVEL_SEGMENT;	
    },
    CRITICAL_RATING = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = 30;
        SoftCap = 55;
        BStart = 50;
        BEnd = 100 * LEVEL_SEGMENT;	
    },
    PHYSICAL_MITIGATION = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = 85;
        SoftCap = 95;
        BStart = 50;
        BEnd = 95 * LEVEL_SEGMENT;	
    },
    TACTICAL_MITIGATION = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = 85;
        SoftCap = 95;
        BStart = 50;
        BEnd = 95 * LEVEL_SEGMENT;	
    },
    MANA_REGEN = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = .5;
        SoftCap = 5;
        BStart = 50;
        BEnd = 125 * LEVEL_SEGMENT;	
    },
    HEALTH_REGEN = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = 200;
        SoftCap = 250;
        BStart = 50;
        BEnd = 75 * LEVEL_SEGMENT;	
    },
    OUTGOING_HEALING = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = 200;
        SoftCap = 300;
        BStart = 50;
        BEnd = 175 * LEVEL_SEGMENT;	
    },
    INCOMING_HEALING = {
        LevelSeg = LEVEL_SEGMENT;
        HardCap = 200;
        SoftCap = 300;
        BStart = 50;
        BEnd = 175 * LEVEL_SEGMENT;	
    },
}

-- [ Types ] --
export type Module = typeof(StatDefaults)

return StatDefaults :: Module
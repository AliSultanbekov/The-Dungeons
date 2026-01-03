--[=[
    @class TopicConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TopicConstants = {}

TopicConstants.UI = {
    OpenedAny = "UI/OpenedAny",
    ClosedAny = "UI/ClosedAny",
    
    Open = function(name: string) return "UI/Open/".. name end,
    Close = function(name: string) return "UI/Close/".. name end,
    Toggle = function(name: string) return "UI/Toggle/".. name end,
    AutoClosed = function(name: string) return "UI/AutoClosed/".. name end,
}

-- [ Types ] --
export type Module = typeof(TopicConstants)

return TopicConstants :: Module
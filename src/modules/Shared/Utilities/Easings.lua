--[=[
    @class Easings
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Easings = {}

-- [ Types ] --
export type Module = typeof(Easings)

-- [ Private Functions ] --

-- [ Public Functions ] --

-- Linear
function Easings.Linear(self: Module, x: number): number
    return x
end

-- Quad (Quadratic)
function Easings.EaseInQuad(self: Module, x: number): number
    return x * x
end

function Easings.EaseOutQuad(self: Module, x: number): number
    return 1 - (1 - x) * (1 - x)
end

function Easings.EaseInOutQuad(self: Module, x: number): number
    return if x < 0.5 then 2 * x * x else 1 - math.pow(-2 * x + 2, 2) / 2
end

-- Cubic
function Easings.EaseInCubic(self: Module, x: number): number
    return x * x * x
end

function Easings.EaseOutCubic(self: Module, x: number): number
    return 1 - math.pow(1 - x, 3)
end

function Easings.EaseInOutCubic(self: Module, x: number): number
    return if x < 0.5 then 4 * x * x * x else 1 - math.pow(-2 * x + 2, 3) / 2
end

-- Quart (Quartic)
function Easings.EaseInQuart(self: Module, x: number): number
    return x * x * x * x
end

function Easings.EaseOutQuart(self: Module, x: number): number
    return 1 - math.pow(1 - x, 4)
end

function Easings.EaseInOutQuart(self: Module, x: number): number
    return if x < 0.5 then 8 * x * x * x * x else 1 - math.pow(-2 * x + 2, 4) / 2
end

-- Quint (Quintic)
function Easings.EaseInQuint(self: Module, x: number): number
    return x * x * x * x * x
end

function Easings.EaseOutQuint(self: Module, x: number): number
    return 1 - math.pow(1 - x, 5)
end

function Easings.EaseInOutQuint(self: Module, x: number): number
    return if x < 0.5 then 16 * x * x * x * x * x else 1 - math.pow(-2 * x + 2, 5) / 2
end

-- Sine
function Easings.EaseInSine(self: Module, x: number): number
    return 1 - math.cos((x * math.pi) / 2)
end

function Easings.EaseOutSine(self: Module, x: number): number
    return math.sin((x * math.pi) / 2)
end

function Easings.EaseInOutSine(self: Module, x: number): number
    return -(math.cos(math.pi * x) - 1) / 2
end

-- Expo (Exponential)
function Easings.EaseInExpo(self: Module, x: number): number
    return if x == 0 then 0 else math.pow(2, 10 * (x - 1))
end

function Easings.EaseOutExpo(self: Module, x: number): number
    return if x == 1 then 1 else 1 - math.pow(2, -10 * x)
end

function Easings.EaseInOutExpo(self: Module, x: number): number
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    elseif x < 0.5 then
        return math.pow(2, 20 * x - 10) / 2
    else
        return (2 - math.pow(2, -20 * x + 10)) / 2
    end
end

-- Circ (Circular)
function Easings.EaseInCirc(self: Module, x: number): number
    return 1 - math.sqrt(1 - math.pow(x, 2))
end

function Easings.EaseOutCirc(self: Module, x: number): number
    return math.sqrt(1 - math.pow(x - 1, 2))
end

function Easings.EaseInOutCirc(self: Module, x: number): number
    return if x < 0.5 then (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2 else (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2
end

-- Back
function Easings.EaseInBack(self: Module, x: number, c1: number?): number
    local c3 = (c1 or 1.70158) + 1
    return c3 * x * x * x - (c1 or 1.70158) * x * x
end

function Easings.EaseOutBack(self: Module, x: number, c1: number?): number
    local c1_val = c1 or 1.70158
    local c3 = c1_val + 1
    return 1 + c3 * math.pow(x - 1, 3) + c1_val * math.pow(x - 1, 2)
end

function Easings.EaseInOutBack(self: Module, x: number, c1: number?): number
    local c1_val = c1 or 1.70158
    local c2 = c1_val * 1.525
    if x < 0.5 then
        return (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
    else
        return (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    end
end

-- Elastic
function Easings.EaseInElastic(self: Module, x: number, c4: number?): number
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    else
        local c4_val = c4 or (2 * math.pi / 3)
        return -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * c4_val)
    end
end

function Easings.EaseOutElastic(self: Module, x: number, c4: number?): number
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    else
        local c4_val = c4 or (2 * math.pi / 3)
        return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4_val) + 1
    end
end

function Easings.EaseInOutElastic(self: Module, x: number, c4: number?): number
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    elseif x < 0.5 then
        local c4_val = c4 or (2 * math.pi / 3)
        return -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c4_val)) / 2
    else
        local c4_val = c4 or (2 * math.pi / 3)
        return (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c4_val)) / 2 + 1
    end
end

-- Bounce
function Easings.EaseInBounce(self: Module, x: number): number
    return 1 - Easings.EaseOutBounce(Easings, 1 - x)
end

function Easings.EaseOutBounce(self: Module, x: number): number
    local n1 = 7.5625
    local d1 = 2.75
    
    if x < 1 / d1 then
        return n1 * x * x
    elseif x < 2 / d1 then
        return n1 * (x - 1.5 / d1) * (x - 1.5 / d1) + 0.75
    elseif x < 2.5 / d1 then
        return n1 * (x - 2.25 / d1) * (x - 2.25 / d1) + 0.9375
    else
        return n1 * (x - 2.625 / d1) * (x - 2.625 / d1) + 0.984375
    end
end

function Easings.EaseInOutBounce(self: Module, x: number): number
    return if x < 0.5 then (1 - Easings.EaseOutBounce(Easings, 1 - 2 * x)) / 2 else (1 + Easings.EaseOutBounce(Easings, 2 * x - 1)) / 2
end

return Easings :: Module
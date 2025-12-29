--[=[
    @class Easings
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local PI = math.pi
local TAU = 2 * math.pi

-- [ Variables ] --

-- [ Module Table ] --
local Easings = {}

-- [ Types ] --
export type Module = typeof(Easings)

-- [ Private Functions ] --

-- [ Public Functions ] --

----------------------------------------------------------------
-- Linear
----------------------------------------------------------------

function Easings.Linear(self: Module, a: number): number
	return a
end

----------------------------------------------------------------
-- Sine
----------------------------------------------------------------

function Easings.InSine(self: Module, a: number): number
	return 1 - math.cos((a * PI) / 2)
end

function Easings.OutSine(self: Module, a: number): number
	return math.sin((a * PI) / 2)
end

function Easings.InOutSine(self: Module, a: number): number
	return -(math.cos(PI * a) - 1) / 2
end

----------------------------------------------------------------
-- Quad
----------------------------------------------------------------

function Easings.InQuad(self: Module, a: number): number
	return a * a
end

function Easings.OutQuad(self: Module, a: number): number
	return 1 - (1 - a) * (1 - a)
end

function Easings.InOutQuad(self: Module, a: number): number
	return a < 0.5 and 2 * a * a or 1 - (-2 * a + 2) ^ 2 / 2
end

----------------------------------------------------------------
-- Cubic
----------------------------------------------------------------

function Easings.InCubic(self: Module, a: number): number
	return a ^ 3
end

function Easings.OutCubic(self: Module, a: number): number
	return 1 - (1 - a) ^ 3
end

function Easings.InOutCubic(self: Module, a: number): number
	return a < 0.5 and 4 * a ^ 3 or 1 - (-2 * a + 2) ^ 3 / 2
end

----------------------------------------------------------------
-- Quart
----------------------------------------------------------------

function Easings.InQuart(self: Module, a: number): number
	return a ^ 4
end

function Easings.OutQuart(self: Module, a: number): number
	return 1 - (1 - a) ^ 4
end

function Easings.InOutQuart(self: Module, a: number): number
	return a < 0.5 and 8 * a ^ 4 or 1 - (-2 * a + 2) ^ 4 / 2
end

----------------------------------------------------------------
-- Quint
----------------------------------------------------------------

function Easings.InQuint(self: Module, a: number): number
	return a ^ 5
end

function Easings.OutQuint(self: Module, a: number): number
	return 1 - (1 - a) ^ 5
end

function Easings.InOutQuint(self: Module, a: number): number
	return a < 0.5 and 16 * a ^ 5 or 1 - (-2 * a + 2) ^ 5 / 2
end

----------------------------------------------------------------
-- Expo
----------------------------------------------------------------

function Easings.InExpo(self: Module, a: number): number
	return a == 0 and 0 or 2 ^ (10 * a - 10)
end

function Easings.OutExpo(self: Module, a: number): number
	return a == 1 and 1 or 1 - 2 ^ (-10 * a)
end

function Easings.InOutExpo(self: Module, a: number): number
	if a == 0 then
		return 0
	end
	if a == 1 then
		return 1
	end

	return a < 0.5
		and (2 ^ (20 * a - 10)) / 2
		or (2 - 2 ^ (-20 * a + 10)) / 2
end

----------------------------------------------------------------
-- Circ
----------------------------------------------------------------

function Easings.InCirc(self: Module, a: number): number
	return 1 - math.sqrt(1 - a * a)
end

function Easings.OutCirc(self: Module, a: number): number
	return math.sqrt(1 - (a - 1) * (a - 1))
end

function Easings.InOutCirc(self: Module, a: number): number
	return a < 0.5
		and (1 - math.sqrt(1 - (2 * a) * (2 * a))) / 2
		or (math.sqrt(1 - (-2 * a + 2) ^ 2) + 1) / 2
end

----------------------------------------------------------------
-- Back
----------------------------------------------------------------

function Easings.InBack(self: Module, a: number): number
	local c1 = 1.70158
	local c3 = c1 + 1
	return c3 * a * a * a - c1 * a * a
end

function Easings.OutBack(self: Module, a: number): number
	local c1 = 1.70158
	local c3 = c1 + 1
	local x = a - 1
	return 1 + c3 * x * x * x + c1 * x * x
end

function Easings.InOutBack(self: Module, a: number): number
	local c1 = 1.70158
	local c2 = c1 * 1.525

	if a < 0.5 then
		local x = 2 * a
		return (x * x * ((c2 + 1) * x - c2)) / 2
	else
		local x = 2 * a - 2
		return (x * x * ((c2 + 1) * x + c2) + 2) / 2
	end
end

----------------------------------------------------------------
-- Elastic
----------------------------------------------------------------

function Easings.InElastic(self: Module, a: number): number
	if a == 0 then
		return 0
	end
	if a == 1 then
		return 1
	end

	local c4 = TAU / 3
	return -2 ^ (10 * a - 10) * math.sin((a * 10 - 10.75) * c4)
end

function Easings.OutElastic(self: Module, a: number): number
	if a == 0 then
		return 0
	end
	if a == 1 then
		return 1
	end

	local c4 = TAU / 3
	return 2 ^ (-10 * a) * math.sin((a * 10 - 0.75) * c4) + 1
end

function Easings.InOutElastic(self: Module, a: number): number
	if a == 0 then
		return 0
	end
	if a == 1 then
		return 1
	end

	local c5 = TAU / 4.5

	if a < 0.5 then
		return -(2 ^ (20 * a - 10) * math.sin((20 * a - 11.125) * c5)) / 2
	else
		return (2 ^ (-20 * a + 10) * math.sin((20 * a - 11.125) * c5)) / 2 + 1
	end
end

----------------------------------------------------------------
-- Bounce
----------------------------------------------------------------

local function outBounce(a: number): number
	local n1 = 7.5625
	local d1 = 2.75

	if a < 1 / d1 then
		return n1 * a * a
	elseif a < 2 / d1 then
		local x = a - 1.5 / d1
		return n1 * x * x + 0.75
	elseif a < 2.5 / d1 then
		local x = a - 2.25 / d1
		return n1 * x * x + 0.9375
	else
		local x = a - 2.625 / d1
		return n1 * x * x + 0.984375
	end
end

function Easings.OutBounce(self: Module, a: number): number
	return outBounce(a)
end

function Easings.InBounce(self: Module, a: number): number
	return 1 - outBounce(1 - a)
end

function Easings.InOutBounce(self: Module, a: number): number
	return a < 0.5
		and (1 - outBounce(1 - 2 * a)) / 2
		or (1 + outBounce(2 * a - 1)) / 2
end

----------------------------------------------------------------
-- Continuous solvers (for camera follow, etc.)
----------------------------------------------------------------

-- Exponential smoothing (cheap spring)
function Easings.Smooth(self: Module, current: Vector3, target: Vector3, k: number, dt: number): Vector3
	return current + (target - current) * (1 - math.exp(-k * dt))
end

-- Critically damped spring (AAA camera style)
function Easings.Spring(self: Module, pos: Vector3, vel: Vector3, target: Vector3, freq: number, dt: number): (Vector3, Vector3)
	local omega = TAU * freq
	local x = pos - target
	local exp = math.exp(-omega * dt)

	local newPos = target + (x * (1 + omega * dt) + vel * dt) * exp
	local newVel = (vel * (1 - omega * dt) - x * (omega * omega * dt)) * exp

	return newPos, newVel
end

----------------------------------------------------------------
-- CFrame helpers
----------------------------------------------------------------

function Easings.SmoothCFrame(self: Module, cf: CFrame, target: CFrame, k: number, dt: number): CFrame
	local alpha = 1 - math.exp(-k * dt)
	local p = self:Smooth(cf.Position, target.Position, k, dt)
	return cf:Lerp(target, alpha) + (p - cf.Position)
end

function Easings.SpringCFrame(self: Module, cf: CFrame, vel: Vector3, target: CFrame, freq: number, dt: number): (CFrame, Vector3)
	local p, v = self:Spring(cf.Position, vel, target.Position, freq, dt)
	local alpha = 1 - math.exp(-freq * dt)
	local lerped = cf:Lerp(target, alpha)
	return lerped + (p - lerped.Position), v
end

return Easings :: Module
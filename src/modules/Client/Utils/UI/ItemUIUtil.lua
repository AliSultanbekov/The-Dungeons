local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[=[
    @class ItemUIUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local CELESTIAL_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0.000, Color3.fromRGB(191, 0, 255)),
	ColorSequenceKeypoint.new(0.181, Color3.fromRGB(43, 138, 255)),
	ColorSequenceKeypoint.new(0.366, Color3.fromRGB(63, 237, 240)),
	ColorSequenceKeypoint.new(0.558, Color3.fromRGB(49, 255, 97)),
	ColorSequenceKeypoint.new(0.777, Color3.fromRGB(248, 224, 45)),
	ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 33, 33))
})

local RARITY_CONFIG: { [string]: RarityColors | CelestialRarityColors } = {
	Common = {
		Corners = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(221, 221, 221) },
		Glow = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(255, 255, 255) },
		Inner = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(85, 85, 85) },
		Outline = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(188, 188, 188) },
		Texture = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(162, 162, 162) },
	},
	Uncommon = {
		Corners = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(32, 212, 12) },
		Glow = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(0, 255, 17) },
		Inner = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(6, 71, 4) },
		Outline = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(25, 185, 0) },
		Texture = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(15, 126, 15) },
	},
	Rare = {
		Corners = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(0, 126, 223) },
		Glow = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(0, 115, 255) },
		Inner = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(0, 34, 71) },
		Outline = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(0, 105, 185) },
		Texture = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(0, 85, 125) },
	},
	Epic = {
		Corners = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(194, 80, 223) },
		Glow = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(249, 83, 255) },
		Inner = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(65, 17, 71) },
		Outline = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(154, 62, 185) },
		Texture = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(134, 63, 150) },
	},
	Legendary = {
		Corners = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(226, 158, 1) },
		Glow = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(255, 193, 6) },
		Inner = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(71, 38, 6) },
		Outline = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(185, 127, 10) },
		Texture = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(136, 89, 12) },
	},
	Mythic = {
		Corners = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(209, 0, 7) },
		Glow = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(255, 0, 4) },
		Inner = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(71, 4, 6) },
		Outline = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(208, 28, 31) },
		Texture = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = Color3.fromRGB(149, 12, 17) },
	},
	Celestial = {
		Corners = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = CELESTIAL_GRADIENT, GradientRotation = 127 },
		Glow = { ImageColor3 = Color3.fromRGB(255, 255, 255), GradientColor = CELESTIAL_GRADIENT, GradientRotation = 127 },
		Inner = { ImageColor3 = Color3.fromRGB(75, 75, 75), GradientColor = CELESTIAL_GRADIENT, GradientRotation = 127 },
		Outline = { ImageColor3 = Color3.fromRGB(200, 200, 200), GradientColor = CELESTIAL_GRADIENT, GradientRotation = 127 },
		Texture = { ImageColor3 = Color3.fromRGB(138, 138, 138), GradientColor = CELESTIAL_GRADIENT, GradientRotation = 127 },
	},
}

-- [ Variables ] --

-- [ Module Table ] --
local ItemUIUtil = {}

-- [ Types ] --
type RarityColors = {
	Corners: { ImageColor3: Color3, GradientColor: Color3 },
	Glow: { ImageColor3: Color3, GradientColor: Color3 },
	Inner: { ImageColor3: Color3, GradientColor: Color3 },
	Outline: { ImageColor3: Color3, GradientColor: Color3 },
	Texture: { ImageColor3: Color3, GradientColor: Color3 },
}

type CelestialRarityColors = {
	Corners: { ImageColor3: Color3, GradientColor: ColorSequence, GradientRotation: number },
	Glow: { ImageColor3: Color3, GradientColor: ColorSequence, GradientRotation: number },
	Inner: { ImageColor3: Color3, GradientColor: ColorSequence, GradientRotation: number },
	Outline: { ImageColor3: Color3, GradientColor: ColorSequence, GradientRotation: number },
	Texture: { ImageColor3: Color3, GradientColor: ColorSequence, GradientRotation: number },
}

type ItemUI = typeof(ReplicatedStorage.Assets.UIs.Inventory.ItemUI)
export type Module = typeof(ItemUIUtil)

-- [ Private Functions ] --
local function applyRarityColors(itemUI: ItemUI, config: RarityColors)
	local elements = { "Corners", "Glow", "Inner", "Outline", "Texture" }
	
	for _, elementName in elements do
		local element = itemUI[elementName]
		local colors = config[elementName]
		
		element.ImageColor3 = colors.ImageColor3
		element.UIGradient.Color = ColorSequence.new(colors.GradientColor, colors.GradientColor)
	end
end

local function applyCelestialColors(itemUI: ItemUI, config: CelestialRarityColors)
	local elements = { "Corners", "Glow", "Inner", "Outline", "Texture" }
	
	for _, elementName in elements do
		local element = itemUI[elementName]
		local colors = config[elementName]
		
		element.ImageColor3 = colors.ImageColor3
		element.UIGradient.Color = colors.GradientColor
		element.UIGradient.Rotation = colors.GradientRotation
	end
end

-- [ Public Functions ] --
function ItemUIUtil.SetupForRarity(self: Module, itemUI: ItemUI, rarity: string)
	local config = RARITY_CONFIG[rarity]
	if not config then
		warn(`[ItemUIUtil] Unknown rarity: {rarity}`)
		return
	end
	
	if rarity == "Celestial" then
		applyCelestialColors(itemUI, config :: CelestialRarityColors)
	else
		applyRarityColors(itemUI, config :: RarityColors)
	end
end

return ItemUIUtil :: Module
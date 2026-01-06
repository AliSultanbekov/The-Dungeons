--[=[
    @class ItemUIClassBuilder
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local GenericTypes = require("./_Types")
local ItemUIClass = require("./_ItemUIClass")

local StackableBehavior = require("./Behaviors/ItemData/_StackableBehavior")
local UniqueBehavior = require("./Behaviors/ItemData/_UniqueBehavior")

local DefaultUIBehavior = require("./Behaviors/UI/_DefaultUIBehavior")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Counter = require("Counter")
local ItemTypes = require("ItemTypes")
local MaterialConfig = require("MaterialConfig")
local WeaponConfig = require("WeaponConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemUIClassBuilder = {}

-- [ Types ] --
type ItemData = ItemTypes.ItemData
type ItemUI = GenericTypes.ItemUI
type ItemDataBehavior = GenericTypes.ItemDataBehavior
export type ItemUIObject = ItemUIClass.Object
export type Module = typeof(ItemUIClassBuilder)

-- [ Private Functions ] --

-- [ Public Functions ] --
function ItemUIClassBuilder.Build(self: Module, itemUI: ItemUI, itemData: ItemData): ItemUIClass.Object
    local ItemCount = Counter.new()
    local MarkedCount = Counter.new()

    if itemData.Type == "Materials" then
        local ItemUIClass = ItemUIClass.new({
            ItemUI = itemUI,
            ItemCount = ItemCount,
            MarkCount = MarkedCount,
            Behaviors = {
                ItemData = StackableBehavior.new({
                    ItemData = itemData,
                    ItemCount = ItemCount,
                    MarkedCount = MarkedCount
                }),
                UI = DefaultUIBehavior.new({
                    ItemUI = itemUI,
                    ItemData = itemData,
                    ItemConfig = MaterialConfig,
                })
            }
        })
        return ItemUIClass
    elseif itemData.Type == "Weapons" then
        local ItemUIClass = ItemUIClass.new({
            ItemUI = itemUI,
            ItemCount = ItemCount,
            MarkCount = MarkedCount,
            Behaviors = {
                ItemData = UniqueBehavior.new({
                    ItemData = itemData,
                    ItemCount = ItemCount,
                    MarkedCount = MarkedCount
                }),
                UI = DefaultUIBehavior.new({
                    ItemUI = itemUI,
                    ItemData = itemData,
                    ItemConfig = WeaponConfig,
                })
            }
        })

        return ItemUIClass
    end
    
    error("Unsupported item type: " .. tostring(itemData.Type))
end

return ItemUIClassBuilder :: Module
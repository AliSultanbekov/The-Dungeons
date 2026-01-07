--[=[
    @class TooltipClassBuilder
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local TooltipClass = require("./_TooltipClass")
local ItemBehavior = require("./Behaviors/_ItemBehavior")
local ItemActionBehavior = require("./Behaviors/_ItemActionBehavior")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TooltipClassBuilder = {}

-- [ Types ] --
export type Params = {
    UI: GuiObject,
    DestroySignal: Signal.Signal<nil>,
}
export type TooltipObject = TooltipClass.Object
export type Module = typeof(TooltipClassBuilder)

-- [ Private Functions ] --

-- [ Public Functions ] --
function TooltipClassBuilder.Build(self: Module, tooltipType: string, ui: GuiObject): TooltipObject
    local DestroySignal = Signal.new()

    if tooltipType == "ItemTooltip" then
        return TooltipClass.new({
            UI = ui,
            DestroySignal = DestroySignal,
            Behavior = ItemBehavior.new({
                UI = ui,
                DestroySignal = DestroySignal,
            })
        })
    elseif tooltipType == "ItemActionTooltip" then
        return TooltipClass.new({
            UI = ui,
            DestroySignal = DestroySignal,
            Behavior = ItemActionBehavior.new({
                UI = ui,
                DestroySignal = DestroySignal,
            })
        })
    end

    error(`Unknown tooltip type "{tooltipType}"`)
end

return TooltipClassBuilder :: Module
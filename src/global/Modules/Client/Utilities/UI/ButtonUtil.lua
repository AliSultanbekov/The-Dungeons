--[=[
    @class ButtonUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local UIAnimUtil = require("UIAnimUtil")

-- [ Constants ] --
local _MOVE_TWEENINFO = TweenInfo.new(0.1)
local PRESS_TWEENINFO = TweenInfo.new(0.1)

local _DEFAULT_TOP_POS = UDim2.new(0.5, 0, 0.42, 0)

-- [ Variables ] --

-- [ Module Table ] --
local ButtonUtil = {
    Cache = {}
}

-- [ Types ] --
export type Module = typeof(ButtonUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function ButtonUtil.Hook(self: Module, button: GuiButton, onHoverIn: () -> ()?, onHoverOut: () -> ()?, onInteract: () -> ()?)
    button.MouseEnter:Connect(function()
        if onHoverIn then
            onHoverIn()
        end
    end)

    button.MouseLeave:Connect(function()
        if onHoverOut then
            onHoverOut()
        end
        
        UIAnimUtil:AnimateUIScale(button, 1, PRESS_TWEENINFO)
    end)

    button.MouseButton1Down:Connect(function()
        UIAnimUtil:AnimateUIScale(button, 0.9, PRESS_TWEENINFO)
    end)

    button.MouseButton1Up:Connect(function()
        UIAnimUtil:AnimateUIScale(button, 1, PRESS_TWEENINFO)

        if onInteract then
            onInteract()
        end
    end)
end

return ButtonUtil :: Module
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
local MOVE_TWEENINFO = TweenInfo.new(0.1)
local PRESS_TWEENINFO = TweenInfo.new(0.1)

local DEFAULT_TOP_POS = UDim2.new(0.5, 0, 0.42, 0)

-- [ Variables ] --

-- [ Module Table ] --
local ButtonUtil = {
    Cache = {}
}

-- [ Types ] --
export type Module = typeof(ButtonUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function ButtonUtil.Hook(self: Module, button: GuiButton, onInteract: () -> ()?)
    local Top = button:FindFirstChild("Top")

    if not Top or not Top:IsA("ImageLabel") then
        warn("[ButtonUtil] Top ImageLabel not found for button: " .. button.Name)
        return
    end

    local Bottom = button:FindFirstChild("Bottom")

    if not Bottom or not Bottom:IsA("ImageLabel") then
        warn("[ButtonUtil] Bottom ImageLabel not found for button: " .. button.Name)
        return
    end

    Top.Position = DEFAULT_TOP_POS

    button.MouseEnter:Connect(function()
        UIAnimUtil:AnimateToPosition(Top, UDim2.new(0.5, 0, 0.5, 0), MOVE_TWEENINFO)
    end)

    button.MouseLeave:Connect(function()
        UIAnimUtil:AnimateToPosition(Top, DEFAULT_TOP_POS, MOVE_TWEENINFO)
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
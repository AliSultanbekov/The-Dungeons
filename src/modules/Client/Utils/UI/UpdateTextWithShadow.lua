--[=[
    @class UpdateTextWithShadow
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UpdateTextWithShadow = function(textLabel: TextLabel, text: string)
    local TitleTop = textLabel:FindFirstChildOfClass("TextLabel")

    if TitleTop then
        TitleTop.Text = text
    end

    textLabel.Text = text
end

-- [ Types ] --
export type Module = typeof(UpdateTextWithShadow)

-- [ Private Functions ] --

-- [ Public Functions ] --

return UpdateTextWithShadow :: Module
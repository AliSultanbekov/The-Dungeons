--[=[
    @class HighlightController
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HighlightController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIController: typeof(require("UIController")),
    _Highlights: { [string]: Highlight }
}

export type Module = typeof(HighlightController) & ModuleData

-- [ Private Functions ] --
function HighlightController.Highlight(self: Module, instance: Instance, highlightName: string)
    local Highlight = self._Highlights[highlightName]
    
    if not Highlight then
        return
    end

    Highlight.Adornee = instance
end

function HighlightController.UnHighlight(self: Module, instance: Instance, highlightName: string)
    local Highlight = self._Highlights[highlightName]

    if not Highlight then
        return
    end

    if Highlight.Adornee == instance then
        Highlight.Adornee = nil
    end
end

function HighlightController.UnHighlightAll(self: Module, highlightName: string)
    local Highlight = self._Highlights[highlightName]

    if not Highlight then
        return
    end

    Highlight.Adornee = nil
end

-- [ Public Functions ] --
function HighlightController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIController = self._ServiceBag:GetService(require("UIController"))

    self._Highlights = {}
end

function HighlightController.Start(self: Module)
    --[[self._UIController:Ready():Then(function()
        local HighlightsScreen = self._UIController:GetScreen("Highlights")

        for _, highlight in HighlightsScreen:GetChildren() do
            if not highlight:IsA("Highlight") then
                continue
            end
    
            self._Highlights[highlight.Name] = highlight
        end
    end)]]
end

return HighlightController :: Module
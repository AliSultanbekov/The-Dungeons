--[=[
    @class AssetProvider
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AssetProvider = {}

-- [ Types ] --
export type Module = typeof(AssetProvider)

-- [ Private Functions ] --

-- [ Public Functions ] --
function AssetProvider.Get<T>(self: Module, path: string): T
    local Segments = path:split("/")
    local CurrentPath = ReplicatedStorage:FindFirstChild("Assets")

    for _, segment in Segments do
        local NewPath = CurrentPath:FindFirstChild(segment)

        if not NewPath then
            error(("[AssetProvider] Could not find asset at segment '%s' in path: %s"):format(
                segment,
                table.concat(Segments, "/")
            ))
        end

        CurrentPath = NewPath
    end

    local Asset = CurrentPath:Clone()

    return Asset
end

return AssetProvider :: Module
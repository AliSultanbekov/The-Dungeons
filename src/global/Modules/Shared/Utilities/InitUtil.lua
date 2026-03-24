--[=[
    @class InitUtil
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --
local SingletonNames = {
    "service",
    "manager",
    "network",
    "eventbus",
}

-- [ Variables ] --

-- [ Module Table ] --
local InitUtil = {}

-- [ Types ] --
export type Module = typeof(InitUtil)

-- [ Private Functions ] --

-- [ Public Functions ] --
function InitUtil.GetContextModules(self: Module, modulesFolder: any, placeName: string): { ModuleScript }
    local ModulesFolderArray = {
        modulesFolder:FindFirstChild("Global"),
        modulesFolder:FindFirstChild(placeName)
    }

    local Registor = {}

    local function handleDescendants(instance: any)
        if not instance:IsA("ModuleScript") then
            return
        end

        if instance.Name == "loader" then
            return
        end

        if instance.Name:lower():find("initmanager") then
            return
        end

        for _, name in SingletonNames do
            if instance.Name:lower():find(name) then
                table.insert(Registor, instance)
                break
            end
        end
    end

    for _, contextFolder in ModulesFolderArray do
        local Shared = contextFolder:FindFirstChild("Shared")

        for _, instance in Shared:GetDescendants() do
            handleDescendants(instance)
        end

        if RunService:IsServer() then
            local Server = contextFolder:FindFirstChild("Server")

            for _, instance in Server:GetDescendants() do
                handleDescendants(instance)
            end
        elseif RunService:IsClient() then
            local Client = contextFolder:FindFirstChild("Client")

            for _, instance in Client:GetDescendants() do
                handleDescendants(instance)
            end
        end
    end

    return Registor
end

return InitUtil :: Module
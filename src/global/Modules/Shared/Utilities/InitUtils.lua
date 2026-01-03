--[=[
    @class InitUtils
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InitUtils = {}

-- [ Types ] --
export type Module = typeof(InitUtils)

-- [ Private Functions ] --

-- [ Public Functions ] --
function InitUtils.GetContextModules(self: Module, modulesFolder: any, placeName: string, context: "Client" | "Server"): { Module }
    local ModulesFolderArray = {
        modulesFolder:FindFirstChild("Global"),
        modulesFolder:FindFirstChild(placeName)
    }

    local Registor = {}

    for _, contextFolder in ModulesFolderArray do
        local Shared = contextFolder:FindFirstChild("Shared")

        for _, instance in Shared:GetDescendants() do
            if not instance:IsA("ModuleScript") then
                continue
            end

            if instance.Name:lower():find("initservice") then
                continue
            end

            if instance.Name:lower():find("service") then
                table.insert(Registor, instance)
            end
        end

        if context == "Server" then
            local Server = contextFolder:FindFirstChild("Server")

            for _, instance in Server:GetDescendants() do
                if not instance:IsA("ModuleScript") then
                    continue
                end

                if instance.Name:lower():find("initservice") then
                    continue
                end

                if instance.Name:lower():find("service") or instance.Name:lower():find("eventbus") then
                    table.insert(Registor, instance)
                end
            end
        elseif context == "Client" then
            local Client = contextFolder:FindFirstChild("Client")

            for _, instance in Client:GetDescendants() do
                if not instance:IsA("ModuleScript") then
                    continue
                end

                if instance.Name:lower():find("initservice") then
                    continue
                end

                if instance.Name:lower():find("service") or instance.Name:lower():find("controller") or instance.Name:lower():find("eventbus") then
                    table.insert(Registor, instance)
                end
            end
        end
    end

    return Registor
end

return InitUtils :: Module
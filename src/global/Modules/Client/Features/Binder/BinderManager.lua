--[=[
    @class BinderBagServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local rbx_require = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")

-- [ Constants ] --

-- [ Variables ] --
local Features = script.Parent.Parent.Parent.Features

-- [ Module Table ] --
local BinderBagServiceClient = {}

-- [ Types ] --
type ComponentModule = {
    Tag: string,
    new: (instance: Instance, serviceBag: ServiceBag.ServiceBag) -> any,
    Binded: (self: any) -> (),
    Unbinded: (self: any) -> (),
    Start: (binder: Binder.Binder<ComponentModule>, serviceBag: ServiceBag.ServiceBag) -> (),
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Components: { [string]: ComponentModule },
    _Binders: { [string]: Binder.Binder<ComponentModule> }
}

export type Module = typeof(BinderBagServiceClient) & ModuleData

-- [ Private Functions ] --
function CreateBinder(module: ComponentModule, serviceBag: ServiceBag.ServiceBag)
    local BinderObject = Binder.new(
        module.Tag, 
        function(instance)
            return module.new(instance, serviceBag)
        end
    )

    return serviceBag:GetService(BinderObject)
end

-- [ Public Functions ] --
function BinderBagServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Components = {}
    self._Binders = {}

    for _, instance in Features:GetDescendants() do
        if not instance:IsA("ModuleScript") or not instance.Name:lower():find("component") then
            continue
        end

        local ComponentModule: ComponentModule = rbx_require(instance)

        self._Components[ComponentModule.Tag] = ComponentModule
        self._Binders[ComponentModule.Tag] = CreateBinder(ComponentModule, self._ServiceBag)
    end
end

function BinderBagServiceClient.Start(self: Module)
    for tag, binder in pairs(self._Binders) do
        local Component = self._Components[tag]

        task.spawn(Component.Start, binder, self._ServiceBag)

        local function onAdded(obj: ComponentModule)
            task.spawn(obj.Binded, obj)
        end

        local function onRemoved(obj: ComponentModule)
            task.spawn(obj.Unbinded, obj)
        end

        binder:GetClassAddedSignal():Connect(onAdded)
        binder:GetClassRemovedSignal():Connect(onRemoved)
    end
end

return BinderBagServiceClient :: Module
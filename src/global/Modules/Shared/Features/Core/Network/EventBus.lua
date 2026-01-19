--[=[
    @class EventBus
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EventBus = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Signals: { [string]: Signal.Signal<any>}
}

export type Module = typeof(EventBus) & ModuleData

-- [ Private Functions ] --
function _GetSignal(self: Module, topic: string)
    local s = self._Signals[topic]

    if not s then
        s = Signal.new()
        self._Signals[topic] = s
    end

    return s
end

-- [ Public Functions ] --
function EventBus.Subscribe(self: Module, topic: string, cb: (packet: any) -> ()): Signal.Connection<any>
    return _GetSignal(self, topic):Connect(cb)
end

function EventBus.Once(self: Module, topic: string, cb: (packet: any) -> ()): Signal.Connection<any>
    return _GetSignal(self, topic):Once(cb)
end

function EventBus.Unsubscribe(self: Module, conn: Signal.Connection<any>)
    if conn then
        conn:Disconnect()
    end
end

function EventBus.Publish(self: Module, topic: string, packet: any)
    _GetSignal(self, topic):Fire(packet)
end

function EventBus.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Signals = {}
end

function EventBus.Start(self: Module)
    
end

return EventBus :: Module
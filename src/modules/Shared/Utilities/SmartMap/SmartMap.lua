--[=[
    @class SmartMap
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 
local Signal = require("Signal")
local Table = require("Table")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local SmartMap = {}
SmartMap.__index = SmartMap

-- [ Types ] --
export type MapData<T> = {
    [string]: T
}

export type MapChange<T> = {
    Added: { [string]: T },
    Updated: { [string]: T },
    Removed: { [string]: T },
}

export type ObjectData<T> = {
    _Seq: number,
    _MapData: MapData<T>,
    _MapChange: MapChange<T>,
    Changed: Signal.Signal<(MapData<T>, MapChange<T>, number, ...any)>
}

export type Object<T> = ObjectData<T> & Module
export type Module = typeof(SmartMap)

-- [ Private Functions ] --

-- [ Public Functions ] --

function SmartMap.new<T>(): Object<T>
    local self = setmetatable({} :: any, SmartMap) :: Object<T>
    self._Seq = 0
    self._MapData = {}
    self._MapChange = {
        Added = {},
        Updated = {},
        Removed = {},
    }
    self.Changed = Signal.new() :: any

    return self
end

function SmartMap.OnDataOnceReady<T>(self: Object<T>, cb: (MapData<T>) -> ())
    if self._Seq > 0 then
        cb(self._MapData)
    else
        local Connection; Connection = self.Changed:Connect(function(mapData: MapData<T>, mapChange: MapChange<T>, seq: number)
            if seq == 1 then
                cb(self._MapData)
            else
                warn("[SmartMap] Weird data issue")
            end

            if Connection then
                Connection:Destroy()
            end
        end)
    end
end

function SmartMap.GetSeq<T>(self: Object<T>): number
    return self._Seq
end

function SmartMap.GetChange<T>(self: Object<T>): MapChange<T>
    return self._MapChange
end

function SmartMap.GetAll<T>(self: Object<T>): MapData<T>
    return self._MapData
end

function SmartMap.Get<T>(self: Object<T>, key: string): T?
    return self._MapData[key]
end

function SmartMap.UpdateData<T>(self: Object<T>, mapChange: MapChange<T>)
    if not mapChange then
        warn("[SmartMap] UpdateData called with nil newData")
        return
    end

    if not mapChange.Added or not mapChange.Removed or not mapChange.Updated then
        warn("[SmartMap] Diff missing Added, Updated, or Removed tables", mapChange)
        return
    end

    local Added, Updated, Removed = mapChange.Added, mapChange.Updated, mapChange.Removed

    for k, v in pairs(Added) do
        if self._MapData[k] then
            mapChange.Added[k] = nil
            warn("[SmartMap] Key '" .. tostring(k) .. "' already exists in _Data during Add; skipping.")
            continue
        end

        self._MapData[k] = v
    end

    for k, v in pairs(Updated) do
        if not self._MapData[k] then
            mapChange.Updated[k] = nil
            warn("[SmartMap] Key '" .. tostring(k) .. "' does not exist in _Data during Update; skipping.")
            continue
        end

        self._MapData[k] = v
    end

    for k, v in pairs(Removed) do
        if self._MapData[k] == nil then
            mapChange.Removed[k] = nil
            warn("[SmartMap] Key '" .. tostring(k) .. "' does not exist in _Data during Remove; skipping.")
            continue
        end

        self._MapData[k] = nil
    end

    local EmptyCount = 0
    for _, v in pairs(mapChange) do
        if next(v) == nil then
            EmptyCount += 1
        end
    end

    if EmptyCount == Table.count(mapChange) then
        warn("[SmartMap] All sections of newData are empty after update.")
        return
    end

    self._Seq += 1
    self._MapChange = mapChange :: any
    self.Changed:Fire(self._MapData, self._MapChange, self._Seq)
end

return SmartMap :: Module
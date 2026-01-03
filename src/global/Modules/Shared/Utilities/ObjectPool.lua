--[=[
    @class ObjectPool
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] -- 

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ObjectPool = {}
ObjectPool.__index = ObjectPool

-- [ Types ] --
type Construct<T> = () -> T
type Deconstruct<T> = (obj: T) -> ()

export type ObjectData<T> = {
    _KeyBucket: {
        [string]: {
            Construct: Construct<T>,
            Deconstruct: Deconstruct<T>,
            Free: { [number]: T },
            Used: { [T]: boolean }
        }
    },
}
export type Object<T> = ObjectData<T> & Module
export type Module = typeof(ObjectPool)

-- [ Private Functions ] --
function ProcessKey(key: string): string
    if key == "" then
        error("[ObjectPool] Key cannot be an empty string.")
    end

    return key
end

-- [ Public Functions ] --
function ObjectPool.new<T>(): Object<T>
    local self = setmetatable({} :: any, ObjectPool) :: Object<T>

    self._KeyBucket = {}

    return self
end

function ObjectPool.KeyExists<T>(self: Object<T>, key: string): boolean
    if self._KeyBucket[key] then
        return true
    else
        return false
    end
end

function ObjectPool.AddKey<T>(self: Object<T>, key: string, Construct: Construct<T>, Deconstruct: Deconstruct<T>)
    if self._KeyBucket[key] then
        warn(("[ObjectPool] Key '%s' already exists."):format(key))
        return
    end

    self._KeyBucket[key] = {
        Construct = Construct,
        Deconstruct = Deconstruct,
        Free = {},
        Used = {},
    }
end

function ObjectPool.ForceConstruct<T>(self: Object<T>, key: string, amount: number?)
    local Key = ProcessKey(key)
    local KeyData = self._KeyBucket[Key]

    local Amount = math.max(1, amount or 5)

    for i = 1, Amount do
        local Obj = KeyData.Construct()
        table.insert(KeyData.Free, Obj)
    end
end

function ObjectPool.Get<T>(self: Object<T>, key: string): T
    local Key = ProcessKey(key)
    local KeyData = self._KeyBucket[Key]

    local N = #KeyData.Free

    if N == 0 then
        self:ForceConstruct(Key)
        N = #KeyData.Free
    end
    
    local Obj = KeyData.Free[N]
    table.remove(KeyData.Free)
    KeyData.Used[Obj] = true

    return Obj
end

function ObjectPool.Return<T>(self: Object<T>, key: string, obj: T)
    local Key = ProcessKey(key)
    local KeyData = self._KeyBucket[Key]

    if not KeyData.Used[obj] then
        warn("[ObjectPool] Attempt to return object that is not currently marked as used for key: " .. Key)
        return
    end

    KeyData.Used[obj] = nil
    KeyData.Deconstruct(obj)   
    table.insert(KeyData.Free, obj)
end

return ObjectPool :: Module
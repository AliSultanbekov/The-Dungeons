--[=[
    @class PositionHistoryService
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --
local HISTORY_LENGTH = 30

-- [ Variables ] --

-- [ Module Table ] --
local PositionHistoryService = {}
-- [ Types ] --
type BufferData = {
    CFrame: CFrame,
    Timestamp: number,
}
type CircularBuffer = {
    Data: { BufferData },
    Head: number,
    Size: number,
}
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PlayerCharacterService: typeof(require("PlayerCharacterService")),
    _CharacterHistory: { [Model]: CircularBuffer }
}

export type Module = typeof(PositionHistoryService) & ModuleData

-- [ Private Functions ] --
function PositionHistoryService._CreateCircularBuffer(self: Module): CircularBuffer
    return {
        Data = table.create(HISTORY_LENGTH),
        Head = 1,
        Size = 0
    }
end

function PositionHistoryService._AddToBuffer(self: Module, buffer: CircularBuffer, data: BufferData)
    buffer.Data[buffer.Head] = data
    buffer.Head = (buffer.Head % HISTORY_LENGTH) + 1
    buffer.Size = math.min(buffer.Size + 1, HISTORY_LENGTH)
end

function PositionHistoryService._OnHeartbeat(self: Module)
    local Now = os.clock()

    for character: Model, buffer in self._CharacterHistory do
        local CFrame = character:GetPivot()

        self:_AddToBuffer(buffer, {CFrame = CFrame, Timestamp = Now})
    end
end

-- [ Public Functions ] --
function PositionHistoryService.GetCFrameAt(self: Module, Character: Model, Timestamp: number): CFrame?
    local Buffer = self._CharacterHistory[Character]

    if not Buffer or Buffer.Size == 0 then
        print("[PositionHistory] No buffer for", Character.Name, "Size:", Buffer and Buffer.Size)
        return nil
    end
    
    -- Find the two entries that bracket the timestamp
    local Before, After
    
    -- Iterate from newest to oldest
    for i = 1, Buffer.Size do
        local Index = (Buffer.Head - 1 - i + HISTORY_LENGTH) % HISTORY_LENGTH + 1
        local Entry = Buffer.Data[Index]
        
        if not Entry then continue end
        
        if Entry.Timestamp <= Timestamp then
            Before = Entry
            
            -- Get the next entry chronologically (after Before)
            if i > 1 then
                local NextIndex = (Buffer.Head - i + HISTORY_LENGTH) % HISTORY_LENGTH + 1
                After = Buffer.Data[NextIndex]
            end
            
            break
        end
    end
    
    -- If no Before entry, timestamp is older than our history
    if not Before then
        return nil
    end
    
    -- If no After entry, timestamp is newer than our newest entry
    -- Return the most recent CFrame
    if not After then
        return Before.CFrame
    end
    
    -- Interpolate between Before and After
    local TimeDelta = After.Timestamp - Before.Timestamp
    
    if TimeDelta < 1e-6 then
        return Before.CFrame
    end
    
    local Alpha = math.clamp((Timestamp - Before.Timestamp) / TimeDelta, 0, 1)
    
    -- Interpolate CFrame: position lerp + rotation slerp
    return Before.CFrame:Lerp(After.CFrame, Alpha)
end

function PositionHistoryService.GetPosition(self: Module, Character: Model, Timestamp: number): Vector3?
    local CF = self:GetCFrameAt(Character, Timestamp)
    return CF and CF.Position or nil
end

function PositionHistoryService.OnPlayerCharacterAdded(self: Module, maid: Maid.Maid, character: Model)
    self._CharacterHistory[character] = self:_CreateCircularBuffer()
    
    maid:Add(function()
        self._CharacterHistory[character] = nil
    end)
end

function PositionHistoryService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PlayerCharacterService = self._ServiceBag:GetService(require("PlayerCharacterService"))
    self._CharacterHistory = {}
end

function PositionHistoryService.Start(self: Module)
    self._PlayerCharacterService:RegisterService(self)

    RunService.Heartbeat:Connect(function(dt: number)
        self:_OnHeartbeat()
    end)

    task.spawn(function()
        task.wait(2)

        for _, instance in workspace:GetChildren() do
            if not instance:IsA("Model") then
                continue
            end

            if not instance:FindFirstChildOfClass("Humanoid") then
                continue
            end

            if self._CharacterHistory[instance] then
                continue
            end

            self._CharacterHistory[instance] = self:_CreateCircularBuffer()
        end
    end)
end

return PositionHistoryService :: Module
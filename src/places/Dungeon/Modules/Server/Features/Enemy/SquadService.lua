--[=[
    @class SquadService
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
-- [ Imports ] --
local NPCGroupUtil = require("./_NPCGroupUtil")
local Types = require("./_Types")

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local GeneralGameConstants = require("GeneralGameConstants")
local ServiceBag = require("ServiceBag")
local AssetProvider = require("AssetProvider")

-- [ Constants ] --
local CONFIG = {
	StartPosition = Vector3.new(0, 0, 0),
	SquadSizeX = 4,
	SquadSizeY = 4,
	Spacing = 5,
	LeaderGap = 8,
	BaseSpeed = 16,
	LeaderThrottle = 0.90,
	CatchupMultiplier = 1.35,
	SwayAmplitude = 2.0,
	SwayFrequency = 1.0,
	SpeedVariance = 0.15,
	ReactionDelay = 0.85,
}

-- [ Variables ] --

-- [ Module Table ] --
local SquadService = {}

-- [ Types ] --
type NPC = typeof(ReplicatedStorage.Assets.Objects.NPC)
type Member = Types.Member
type Config = Types.Config
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,

	_Config: Config,
	_Members: { Member },
	_IsMoving: boolean,
	_IsGuarding: boolean,
	_FormationFacing: Vector3,
	_Waypoints: {},
	_CurrentWaypointIndex: number,
	_FormationCFrame: CFrame,

	_NPCFolder: Folder,
	_NPCTemplate: NPC,

	_Heartbeat: RBXScriptConnection?,
	_Leader: Member?,
	_NPCHelper : typeof(NPCHelper),
}

export type Module = typeof(SquadService) & ModuleData

-- [ Private Functions ] --
function SquadService._CreateSquadFolder(): Folder
	local NPCFolder = Instance.new("Folder", workspace)
	NPCFolder.Name = "SquadNPCs"
	return NPCFolder
end

-- [ Public Functions ] --
function SquadService.InitializeSquad(self: Module)
	self._NPCFolder:ClearAllChildren()
	self._Members = {}


	-- Spawn Leader
	local Leader = NPCGroupUtil:CreateMember(0, 0, true, 0, self._Config, self._NPCTemplate, self._NPCFolder)
	Leader.RootPart.CFrame = CFrame.new(self._Config.StartPosition)
	table.insert(self._Members, Leader)
	self._Leader = Leader

	Leader.ID = self._NPCHelper:CreateNewNPCEntity("EliteEnemy", Leader)
	

	-- Spawn Squad
	for y = 1, self._Config.SquadSizeY do
		for x = 1, self._Config.SquadSizeX do
			local Mem = NPCGroupUtil:CreateMember(x, y, false, 0, self._Config, self._NPCTemplate, self._NPCFolder)
			local SpawnPos = self._Config.StartPosition + Vector3.new(Mem.Offset.X, 0, Mem.Offset.Z)
			Mem.RootPart.CFrame = CFrame.new(SpawnPos)
			table.insert(self._Members, Mem)
			

			Mem.ID = self._NPCHelper:CreateNewNPCEntity("Basic", Mem)
		end
	end

	-- Start the "Idle Animations" loop (Scanning)
	task.spawn(function()
		while true do
			task.wait(math.random(2, 6))
			self:UpdateScanningBehavior()
		end
	end)

	print("Tactical Squad Initialized")
end

function SquadService.UpdateScanningBehavior(self: Module)
	local Candidate = self._Members[math.random(1, #self._Members)]
	if Candidate.IsLeader then return end

	if Candidate.Neck and not Candidate.IsScanning then
		Candidate.IsScanning = true
		local OriginalC0 = CFrame.new(0, 0.8, 0)

		local Angle = math.rad(math.random(-45, 45))
		local LookCFrame = OriginalC0 * CFrame.Angles(0, Angle, 0)

		local Tween = TweenService:Create(Candidate.Neck, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {C0 = LookCFrame})
		Tween:Play()

		task.delay(math.random(1, 2), function()
			local Reset = TweenService:Create(Candidate.Neck, TweenInfo.new(0.6), {C0 = OriginalC0})
			Reset:Play()
			Candidate.IsScanning = false
		end)
	end
end

function SquadService.UpdateSquadStep(self: Module, dt: number)
	if not self._IsMoving then return end

	local Leader
	for _, member in ipairs(self._Members) do
		if member.IsLeader then
			Leader = member
			break
		end
	end

	if not Leader then return end

	local Now = os.clock()
	local Waypoint = self._Waypoints[self._CurrentWaypointIndex]
	if not Waypoint then
		self.Stop(self)
		return
	end

	local LeaderPos = Leader.RootPart.Position
	local VecToWaypoint = NPCGroupUtil:GetFlatVector(Waypoint.Position - LeaderPos)

	if VecToWaypoint.Magnitude > 0.1 then
		local GoalLook = VecToWaypoint.Unit
		self._FormationFacing = self._FormationFacing:Lerp(GoalLook, dt * 2.5).Unit
	end

	if VecToWaypoint.Magnitude < 4 then
		self._CurrentWaypointIndex += 1
		if self._CurrentWaypointIndex > #self._Waypoints then
			self:EnterGuardMode()
			return
		end
	end

	local FormationCF = CFrame.lookAt(LeaderPos, LeaderPos + self._FormationFacing)

	for _, member in ipairs(self._Members) do
		local TargetPos
		local BaseSpeed = self._Config.BaseSpeed

		if member.IsLeader then
			TargetPos = Waypoint.Position
			BaseSpeed = BaseSpeed * self._Config.LeaderThrottle
		else
			local SlotPos = LeaderPos 
				+ (FormationCF.RightVector * member.Offset.X) 
				- (FormationCF.LookVector * member.Offset.Z)

			local Drift = NPCGroupUtil:GetNoiseOffset(member.Seed, Now, self._Config.SwayFrequency, self._Config.SwayAmplitude)
			TargetPos = NPCGroupUtil.RaycastToFloor(SlotPos + Drift, {self._NPCFolder})
		end

		local Dist = NPCGroupUtil:GetFlatDistance(member.RootPart.Position, TargetPos)

		local SpeedPulse = 1 + (math.sin(Now * 3 + member.Seed) * self._Config.SpeedVariance)
		local FinalSpeed = BaseSpeed * SpeedPulse

		if Dist > 3 then
			FinalSpeed *= self._Config.CatchupMultiplier
		elseif Dist < 1 then
			FinalSpeed *= 0.8
		end

		if (member.TargetPos - TargetPos).Magnitude > 0.5 then
			member.TargetPos = TargetPos
			member.Humanoid:MoveTo(TargetPos)
		end

		member.Humanoid.WalkSpeed = FinalSpeed
	end
end

function SquadService.MoveTo(self: Module, targetPos: Vector3)
	self._IsGuarding = false -- Stop guarding when moving
	if not self._Leader then return end

	local path = PathfindingService:CreatePath({
		AgentRadius = 3,
		AgentCanJump = false,
		WaypointSpacing = 10
	})

	local success = pcall(function()
		path:ComputeAsync(self._Leader.RootPart.Position, targetPos)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		self._Waypoints = path:GetWaypoints()
		self._CurrentWaypointIndex = 2
		self._IsMoving = true

		if self._Heartbeat then self._Heartbeat:Disconnect() end
		self._Heartbeat = RunService.Heartbeat:Connect(function(dt)
			self:UpdateSquadStep(dt)
		end)
	else
		warn("Pathfinding failed or blocked")
	end
end

function SquadService.EnterGuardMode(self: Module)
	if self._Heartbeat then
		self._Heartbeat:Disconnect()
		self._Heartbeat = nil
	end

	self._IsMoving = false
	self._IsGuarding = true

	-- 1. Spread out to random positions
	for _, member in ipairs(self._Members) do
		local Angle = math.random() * math.pi * 2
		local Radius = math.random(5, 30) -- Spread out more
		local Offset = Vector3.new(math.cos(Angle) * Radius, 0, math.sin(Angle) * Radius)
		
		-- Raycast to find a valid spot on the floor
		local Target = NPCGroupUtil.RaycastToFloor(member.RootPart.Position + Offset, {self._NPCFolder})
		
		member.GuardPosition = Target -- Store their "post"
		member.Humanoid:MoveTo(Target)
	end

	-- 2. Start Individual Guard Behavior Loop
	task.spawn(function()
		while self._IsGuarding do
			task.wait(math.random(3, 6))
			if not self._IsGuarding then break end

			for _, member in ipairs(self._Members) do
				-- Chance to wander slightly around their post
				if math.random() > 0.6 and member.GuardPosition then
					local WanderRadius = 25
					local WX = math.random(-WanderRadius, WanderRadius)
					local WZ = math.random(-WanderRadius, WanderRadius)
					local WanderTarget = member.GuardPosition + Vector3.new(WX, 0, WZ)
					
					member.Humanoid:MoveTo(WanderTarget)
				end
			end
		end
	end)
end

function SquadService.Stop(self: Module)
	self._IsMoving = false

	if self._Heartbeat then
		self._Heartbeat:Disconnect()
		self._Heartbeat = nil
	end

	for _, member in ipairs(self._Members) do
		member.Humanoid:MoveTo(member.RootPart.Position)
	end
end

function SquadService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")

	self._Config = {
		StartPosition = Vector3.new(0, 0, 0),
		SquadSizeX = 4,
		SquadSizeY = 4,
		Spacing = 5,
		LeaderGap = 8,
		BaseSpeed = 16,
		LeaderThrottle = 0.90,
		CatchupMultiplier = 1.35,
		SwayAmplitude = 2.0,
		SwayFrequency = 1.0,
		SpeedVariance = 0.15,
		ReactionDelay = 0.85,
	}
	self._Members = {}
	self._IsMoving = false
	self._IsGuarding = false
	self._FormationFacing = Vector3.new(0, 0, 1)
	self._Waypoints = {}
	self._CurrentWaypointIndex = 1
	self._FormationCFrame = CFrame.new(CONFIG.StartPosition)
	self._NPCFolder = self._CreateSquadFolder()
	self._NPCTemplate = AssetProvider:Get("Objects/NPC") :: NPC
	self._NPCHelper = GeneralGameConstants.NPC_HELPER
end

function SquadService.Start(self: Module)
	task.spawn(function()
		self:InitializeSquad()

		while true do
			task.wait(2)
			if not self._IsMoving then
				-- Pick a random point
				local target = self._Config.StartPosition + Vector3.new(-100, 0, 100)

				print("Squad Moving to:", target)
				self:MoveTo(target)
				break
			end
		end
	end)
end

return SquadService :: Module
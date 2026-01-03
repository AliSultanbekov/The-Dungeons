export type Member = {
    ID: number,
    Model: Model,
    Humanoid: Humanoid,
    RootPart: BasePart,
    Neck: BasePart?,
    GridX: number,
    GridY: number,
    Offset: Vector3,
    IsLeader: boolean,
    Seed: number,
    LastPos: Vector3,
    TargetPos: Vector3,
    CurrentSpeed: number,
    IsScanning: boolean,
    GuardPosition: Vector3?,
}

export type Config = typeof({
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
})

return nil
///////////////////////////////////////////////////////////////////////////////
// PLCowBossPawn
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Same as the AW cowboss, but rebalanced a bit for the apocalypse conqueror fight
///////////////////////////////////////////////////////////////////////////////
class PLCowBossPawn extends AWCowBossPawn;

defaultproperties
{
	ActorID="PLCowBossPawn"

	ChargeGroundSpeed=1250.000000
	EyeOffset=(Z=400.000000)
	SquirtSpeedMin=300.000000
	SquirtSpeedMax=500.000000
	HealthMax=2000.000000
	WalkingPct=0.400000
	ControllerClass=Class'PLCowBossController'
	AmbientGlow=30
	Gang="ZombieGang"
}
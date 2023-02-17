///////////////////////////////////////////////////////////////////////////////
// MadCowPawn for Postal 2 AW
//
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class PLMadCowPawn extends PLCowPawn;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var (PawnAttributes) float PickTargetFreq;
var (PawnAttributes) float PickDudeFreq;

defaultproperties
{
	PickTargetFreq=0.500000
	PickDudeFreq=1.000000
	CalmDownFreq=0.200000
	TakesSledgeDamage=0.150000
	ExplodeHeadSound=Sound'WeaponSounds.flesh_explode'
	bZombie=True
	bDiesAfterMilked=true
	HeadClass=Class'AWPawns.AWHeadMadCow'
	ControllerClass=Class'PLMadCowController'
	Skins(0)=Texture'AW_Characters.Zombie_Cows.AW_Cow1'
	Gang="EbolaCow"
}

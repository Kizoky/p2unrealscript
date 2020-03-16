///////////////////////////////////////////////////////////////////////////////
// MadCowPawn for Postal 2 AW
//
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class MadCowPawn extends AWCowPawn
	placeable;

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
     CowNormalMoo(0)=Sound'AWSoundFX.Cow.cowmoo1'
     CowNormalMoo(1)=Sound'AWSoundFX.Cow.cowmoo2'
     CowNormalMoo(2)=Sound'AWSoundFX.Cow.cowmoo3'
     CowHurtMoo(0)=Sound'AWSoundFX.Cow.cowhurt1'
     CowHurtMoo(1)=Sound'AWSoundFX.Cow.cowhurt2'
     HeadClass=Class'AWPawns.AWHeadMadCow'
     ControllerClass=Class'AWPawns.MadCowController'
     LODBias=2.000000
     Skins(0)=Texture'AW_Characters.Zombie_Cows.AW_Cow1'
}

//=============================================================================
// AWZombieSuperCharger
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Races close to enemy very quickly
//
//=============================================================================
class AWZombieSuperCharger extends AWZombie
	placeable;

defaultproperties
{
     ChargeFreq=0.700000
     PreSledgeChargeFreq=1.000000
	ControllerClass=class'AWZombieController'
	
	
	// Man Chrzan: xPatch
	 OldHeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_M05'
     OldHeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	 OldBodyMesh=SkeletalMesh'AWCharacters.Zombie_Dude'
     OldBodySkin=Texture'AW_Characters.Zombie_Skins.Zombie_skin_M05'
}

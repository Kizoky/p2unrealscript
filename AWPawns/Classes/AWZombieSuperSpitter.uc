//=============================================================================
// AWZombieSuperSpitter
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Spits very, very frequently
//
//=============================================================================
class AWZombieSuperSpitter extends AWZombie
	placeable;

defaultproperties
{
     VomitFreq=0.700000
	ControllerClass=class'AWZombieController'
	
	// Man Chrzan: xPatch
	 OldHeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_M04'
     OldHeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	 OldBodyMesh=SkeletalMesh'AWCharacters.Zombie_M_SS_Pants'
     OldBodySkin=Texture'AW_Characters.Zombie_Skins.Zombie_skin_M04'
}

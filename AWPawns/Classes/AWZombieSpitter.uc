//=============================================================================
// AWZombieSpitter
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Spits more frequently
//
//=============================================================================
class AWZombieSpitter extends AWZombie
	placeable;

defaultproperties
{
     VomitFreq=0.550000
	ControllerClass=class'AWZombieController'
	
	// Man Chrzan: xPatch
	 OldHeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_M01'
     OldHeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	 OldBodyMesh=SkeletalMesh'AWCharacters.Zombie_M_Jacket_Pants'
     OldBodySkin=Texture'AW_Characters.Zombie_Skins.Zombie_skin_M01'
}

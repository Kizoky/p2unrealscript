//=============================================================================
// AWZombieCharger
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Charges you more often
//
//=============================================================================
class AWZombieCharger extends AWZombie
	placeable;

defaultproperties
{
	ChargeFreq=0.550000
	PreSledgeChargeFreq=0.800000
	ControllerClass=class'AWZombieController'
	//HeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_M02'
	//HeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	//Mesh=SkeletalMesh'AWCharacters.Zombie_M_Jacket_Pants'
	//Skins(0)=Texture'AW_Characters.Zombie_Skins.Zombie_skin_M02'
	Skins(0)=Texture'AW7_EDZombies.Misc.XX__142__Fem_SS_Shorts'
	
	// Man Chrzan: xPatch
	OldHeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_M02'
	OldHeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	OldBodyMesh=SkeletalMesh'AWCharacters.Zombie_M_Jacket_Pants'
	OldBodySkin=Texture'AW_Characters.Zombie_Skins.Zombie_skin_M02'
}

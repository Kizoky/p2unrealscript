//=============================================================================
// AWZombieTom
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class AWZombieTom extends AWZombie
	placeable;

defaultproperties
{
	ControllerClass=class'AWZombieController'
	//HeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_M03'
	//HeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	//Mesh=SkeletalMesh'AWCharacters.Zombie_M_SS_Pants'
	//Skins(0)=Texture'AW_Characters.Zombie_Skins.Zombie_skin_M03'
	Skins(0)=Texture'AW7_EDZombies.Misc.XX__142__Fem_SS_Shorts'
	
	// Man Chrzan: xPatch
	 OldHeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_M03'
     OldHeadMesh=SkeletalMesh'AW_Heads.AW_Zombie'
	 OldBodyMesh=SkeletalMesh'AWCharacters.Zombie_M_SS_Pants'
     OldBodySkin=Texture'AW_Characters.Zombie_Skins.Zombie_skin_M03'
}

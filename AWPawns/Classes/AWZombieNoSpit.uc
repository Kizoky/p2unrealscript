//=============================================================================
// AWZombieNoSpit
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Never spits
//
//=============================================================================
class AWZombieNoSpit extends AWZombie
	placeable;

defaultproperties
{
     VomitFreq=0.000000
     PreSledgeChargeFreq=0.300000
     PreSledgeAttackFreq=1.000000
     PreSledgeFleeFreq=1.000000
	ControllerClass=class'AWZombieController'
	
	// Man Chrzan: xPatch
	 OldHeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_F06'
     OldHeadMesh=SkeletalMesh'heads.FemSH'
	 OldBodyMesh=SkeletalMesh'AWCharacters.Zombie_Fem_LS_Pants'
     OldBodySkin=Texture'AW_Characters.Zombie_Skins.Zombie_skin_F06'
}

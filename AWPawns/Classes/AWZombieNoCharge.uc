//=============================================================================
// AWZombieNoCharge
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Never charges at you, running to get to you faster--always staggers along very slowly
//=============================================================================
class AWZombieNoCharge extends AWZombie
	placeable;

defaultproperties
{
     ChargeFreq=0.000000
     PreSledgeChargeFreq=0.000000
     PreSledgeAttackFreq=0.500000
     PreSledgeFleeFreq=1.000000
	ControllerClass=class'AWZombieController'
	
	// Man Chrzan: xPatch
	 OldHeadSkin=Texture'AW_Characters.Zombie_Heads.Zombie_head_F07'
     OldHeadMesh=SkeletalMesh'heads.FemSHCropped'
     OldBodyMesh=SkeletalMesh'AWCharacters.Zombie_Fem_LS_Skirt'
     OldBodySkin=Texture'AW_Characters.Zombie_Skins.Zombie_Skin_F07'
}

///////////////////////////////////////////////////////////////////////////////
// StumpSurvivalist
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Override stump class for Survivalists
//
///////////////////////////////////////////////////////////////////////////////
class StumpSurvivalist extends Stump;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var() Material OverrideSkin;		// Override skin

///////////////////////////////////////////////////////////////////////////////
// Setup the stump
///////////////////////////////////////////////////////////////////////////////
simulated function SetupStump(Material NewSkin, byte NewAmbientGlow,
							 bool bNewFat, bool bNewFemale, bool bNewPants,
							 bool bNewSkirt)
{
	NewSkin=OverrideSkin;
	Super.SetupStump(NewSkin, NewAmbientGlow, bNewFat, bNewFemale, bNewPants, bNewSkirt);
}

defaultproperties
{
	OverrideSkin=Texture'PLCharacterSkins.Gibs.Gib_Survivalist'
     Meshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump_big'
     Meshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump_big'
     Meshes(2)=StaticMesh'awpeoplestatic.Limbs.L_arm_stump_big'
     Meshes(3)=StaticMesh'awpeoplestatic.Limbs.R_arm_stump_big'
     Meshes(4)=StaticMesh'awpeoplestatic.Limbs.male_upper_torso'
     Meshes(5)=StaticMesh'awpeoplestatic.Limbs.male_lower_torso'
     FemaleMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump_Fem'
     FemaleMeshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump_Fem'
     FemaleMeshes(4)=StaticMesh'awpeoplestatic.Limbs.fem_upper_torso'
     FemaleMeshes(5)=StaticMesh'awpeoplestatic.Limbs.fem_lower_torso'
     SkirtMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump_skirt'
     SkirtMeshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump_skirt'
     Skins(0)=Texture'ChameleonSkins.Special.RWS_Shorts'
}

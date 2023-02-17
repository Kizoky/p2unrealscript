///////////////////////////////////////////////////////////////////////////////
// StumpLawmen
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Override stump class for Lawmen
//
///////////////////////////////////////////////////////////////////////////////
class StumpLawmen extends Stump;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var Material BluS1, BluS2, BrnS1, BrnS2, WhtS1, WhtS2, WC, BlkJ, BrnJ;

///////////////////////////////////////////////////////////////////////////////
// Setup the stump
///////////////////////////////////////////////////////////////////////////////
simulated function SetupStump(Material NewSkin, byte NewAmbientGlow,
							 bool bNewFat, bool bNewFemale, bool bNewPants,
							 bool bNewSkirt)
{
	local String CoatColor, ShirtColor, GibName;
	local Material GibSkin;
	
	// This is painful. - K
	if (Owner.Skins[0] == BluS1
		|| Owner.Skins[0] == BluS2)
		ShirtColor = "BluS";
	else if (Owner.Skins[0] == BrnS1
		|| Owner.Skins[0] == BrnS2)
		ShirtColor = "BrnS";
	else if (Owner.Skins[0] == WhtS1
		|| Owner.Skins[0] == WhtS2)
		ShirtColor = "WhtS";
	if (Owner.Skins[1] == WC)
		CoatColor = "WC";
	else if (Owner.Skins[1] == BlkJ)
		CoatColor = "BlkJ";
	else if (Owner.Skins[1] == BrnJ)
		CoatColor = "BrnJ";
	GibName = "PLCharacterSkins.Gibs.Gib_LM_" $ CoatColor $ "_" $ ShirtColor;
	GibSkin = Material(DynamicLoadObject(GibName, class'Material'));

	Super.SetupStump(GibSkin, NewAmbientGlow, bNewFat, bNewFemale, bNewPants, bNewSkirt);
}

defaultproperties
{
	BluS1=Texture'PLCharacterSkins.Lawmen.MW__310__Avg_Lawman_Jacket'
	BrnS1=Texture'PLCharacterSkins.Lawmen.MW__311__Avg_Lawman_Jacket'
	WhtS1=Texture'PLCharacterSkins.Lawmen.MW__312__Avg_Lawman_Jacket'
	WC=Shader'PLCharacterSkins.Lawmen.Lawman_Coat_Hidden'
	BlkJ=Texture'PLCharacterSkins.Lawmen.Lawman_Coat_Black'
	BrnJ=Texture'PLCharacterSkins.Lawmen.Lawman_Coat_Brown'
     Meshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump'
     Meshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump'
     Meshes(2)=StaticMesh'awpeoplestatic.Limbs.L_arm_stump'
     Meshes(3)=StaticMesh'awpeoplestatic.Limbs.R_arm_stump'
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

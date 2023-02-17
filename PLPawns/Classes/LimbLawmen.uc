///////////////////////////////////////////////////////////////////////////////
// LimbLawmen
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Override limb class for Lawmen
///////////////////////////////////////////////////////////////////////////////
class LimbLawmen extends Limb;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var Material BluS1, BluS2, BrnS1, BrnS2, WhtS1, WhtS2, WC, BlkJ, BrnJ;

///////////////////////////////////////////////////////////////////////////////
// Setup the limb
///////////////////////////////////////////////////////////////////////////////
simulated function SetupLimb(Material NewSkin, byte NewAmbientGlow, rotator LimbRot,
							 bool bNewFat, bool bNewFemale, bool bNewPants)
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
	
	Super.SetupLimb(GibSkin, NewAmbientGlow, LimbRot, bNewFat, bNewFemale, bNewPants);	
}

defaultproperties
{
	BluS1=Texture'PLCharacterSkins.Lawmen.MW__310__Avg_Lawman_Jacket'
	BrnS1=Texture'PLCharacterSkins.Lawmen.MW__311__Avg_Lawman_Jacket'
	WhtS1=Texture'PLCharacterSkins.Lawmen.MW__312__Avg_Lawman_Jacket'
	WC=Shader'PLCharacterSkins.Lawmen.Lawman_Coat_Hidden'
	BlkJ=Texture'PLCharacterSkins.Lawmen.Lawman_Coat_Black'
	BrnJ=Texture'PLCharacterSkins.Lawmen.Lawman_Coat_Brown'
     LimbBounce(0)=Sound'AWSoundFX.Body.limbflop1'
     LimbBounce(1)=Sound'AWSoundFX.Body.limbflop2'
     Meshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_limb_pants'
     Meshes(1)=StaticMesh'awpeoplestatic.Limbs.L_leg_calf_pants'
     Meshes(2)=StaticMesh'awpeoplestatic.Limbs.L_leg_foot_pants'
     Meshes(3)=StaticMesh'awpeoplestatic.Limbs.R_leg_limb_pants'
     Meshes(4)=StaticMesh'awpeoplestatic.Limbs.R_leg_calf_pants'
     Meshes(5)=StaticMesh'awpeoplestatic.Limbs.R_leg_foot_pants'
     Meshes(6)=StaticMesh'awpeoplestatic.Limbs.L_arm_limb'
     Meshes(7)=StaticMesh'awpeoplestatic.Limbs.L_arm_forearm'
     Meshes(8)=StaticMesh'awpeoplestatic.Limbs.L_hand'
     Meshes(9)=StaticMesh'awpeoplestatic.Limbs.R_arm_limb'
     Meshes(10)=StaticMesh'awpeoplestatic.Limbs.R_arm_forearm'
     Meshes(11)=StaticMesh'awpeoplestatic.Limbs.R_hand'
     SleeveMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_limb_pants'
     SleeveMeshes(1)=StaticMesh'awpeoplestatic.Limbs.L_leg_foot_pants'
     SleeveMeshes(2)=StaticMesh'awpeoplestatic.Limbs.L_leg_calf_pants'
     SleeveMeshes(3)=StaticMesh'awpeoplestatic.Limbs.R_leg_limb_pants'
     SleeveMeshes(4)=StaticMesh'awpeoplestatic.Limbs.R_leg_foot_pants'
     SleeveMeshes(5)=StaticMesh'awpeoplestatic.Limbs.R_leg_calf_pants'
     StaticMesh=StaticMesh'awpeoplestatic.Limbs.L_arm_limb'
     Skins(0)=Texture'ChameleonSkins.Special.RWS_Shorts'
}

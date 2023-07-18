///////////////////////////////////////////////////////////////////////////////
// BatonWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Police baton weapon (first and third person).
//
// Low damage bludgeoning attacks.
//
// Enhanced mode: explodes heads with one hit.
//
///////////////////////////////////////////////////////////////////////////////
class DustersWeapon extends FistsWeapon;


// Removed by Man Chrzan: xPatch 2.0 (It's handled in FistsWeapon now)
/* var array<Material> FistBloodTextures;
var int FistBloodSkinIndex;

///////////////////////////////////////////////////////////////////////////////
// Set the texture that would handle the blood
///////////////////////////////////////////////////////////////////////////////
function SetFistBloodTexture(Material NewTex)
{
	Skins[FistBloodSkinIndex] = NewTex;
}

///////////////////////////////////////////////////////////////////////////////
// Add more blood the weapon by incrementing into the blood texture array for
// skins
///////////////////////////////////////////////////////////////////////////////
function DrewBlood()
{
	// Can add more blood, so do
	if(BloodTextureIndex < BloodTextures.Length)
	{
		// update the texture
		SetBloodTexture(BloodTextures[BloodTextureIndex]);
		SetFistBloodTexture(FistBloodTextures[BloodTextureIndex]);
		BloodTextureIndex++;
	}
	//log(self$" drew blood "$BloodTextureIndex$" new skin "$Skins[1]);
}

///////////////////////////////////////////////////////////////////////////////
// Remove all blood from blade
///////////////////////////////////////////////////////////////////////////////
function CleanWeapon()
{
	BloodTextureIndex = 0;
	SetBloodTexture(default.Skins[BloodSkinIndex]);
	SetFistBloodTexture(default.Skins[FistBloodSkinIndex]);
	//log(self$" clean weapon "$BloodTextureIndex$" new skin "$Skins[1]);
}
*/

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ItemName="Dusters"
	AmmoName=class'DustersAmmoInv'
	PickupClass=class'DustersPickup'
	AttachmentClass=class'DustersAttachment'
	Skins[0]=Shader'AW7EDTex.Weapons.Dustersfinal'
	WeaponSpeedShoot1=1.00
	WeaponSpeedShoot2=1.00
	WeaponSpeedShoot1Rand=0.100000
	WeaponSpeedShoot2Rand=0.100000
	bArrestableWeapon=true
	bCanThrow=true
	GroupOffset=3
	DropWeaponHint1="Press %KEY_ThrowWeapon% to drop your weapon."
	DropWeaponHint2=""

	// Change by Man Chrzan: xPatch 2.0 
	//BloodTextures[0]=Texture'ED_WeaponSkins.Melee.DustersBloodMed'
	//BloodTextures[1]=Texture'ED_WeaponSkins.Melee.DustersBloodHigh'
	BloodTextures[0]=Shader'xPatchTex.Weapons.Dusters_BloodyShad1'
	BloodTextures[1]=Shader'xPatchTex.Weapons.Dusters_BloodyShad2'
	BloodSkinIndex=0
	ThirdPersonBloodSkinIndex=0
	
	// Change by Man Chrzan: xPatch 2.0 
	//FistBloodTextures[0]=Texture'WeaponSkins_Bloody.LS_hands_dude_blood01'
	//FistBloodTextures[1]=Texture'WeaponSkins_Bloody.LS_hands_dude_blood02'
	FistsBloodTextures[0]=Texture'xPatchTex.Weapons.Fists_Bloody1'
	FistsBloodTextures[1]=Texture'xPatchTex.Weapons.Fists_Bloody2'
	FistsBloodTextures[2]=Texture'xPatchTex.Weapons.Fists_Bloody3'
	FistBloodSkinIndex=1
	
	bBumpStartsFight=true
	bCannotBeStolen=false
}

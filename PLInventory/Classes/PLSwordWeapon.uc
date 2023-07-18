///////////////////////////////////////////////////////////////////////////////
// PLSwordWeapon
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// "What does 'katana' mean?" "It means 'Japanese sword'."
///////////////////////////////////////////////////////////////////////////////
class PLSwordWeapon extends MacheteWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars consts etc.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Based on about where you'll hit the pawn in front of us, pick an animation
// to play when swinging
///////////////////////////////////////////////////////////////////////////////
function name PickFireAnim()
{
	if (Rand(2) == 0)
		return 'Shoot1a';
	else
		return 'Shoot1b';
}

///////////////////////////////////////////////////////////////////////////////
// Play our proper idling animation
///////////////////////////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	if (FRand() < 0.25)
	{
		if (FRand() < 0.5)
			PlayAnim('Idle_Taunt1', WeaponSpeedIdle, 0.0);
		else
			PlayAnim('Idle_Taunt2', WeaponSpeedIdle, 0.0);
	}
	else
		PlayAnim('Idle', WeaponSpeedIdle, 0.0);
}


defaultproperties
{
	Mesh=SkeletalMesh'PL_Katana_Anims.FP_Katana'
	HudHint1="Press %KEY_Fire% to slice!"
	HudHint2="Press %KEY_AltFire% to dice!"
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
// Change by Man Chrzan: xPatch 2.0
	Skins[1]=Texture'KatanaTex.Blade'					//'PLCharacterSkins.SlimBitch.Blade_optimized_DiffuseMap'
	BloodTextures[0]=Texture'KatanaTex.Blade_blood1' 	//'PLCharacterSkins.SlimBitch.Blade_optimized_DiffuseMap'
	BloodTextures[1]=Texture'KatanaTex.Blade_blood2' 	//'PLCharacterSkins.SlimBitch.Blade_optimized_DiffuseMap'
	AttachmentClass=class'PLSwordAttachment'
	PickupClass=class'PLSwordPickup'
	AmmoName=class'PLSwordAmmoInv'
	GroupOffset=15
	ThirdPersonRelativeLocation=(X=8,Y=-1,Z=-13)
	ItemName="Katana"
	PlayerViewOffset=(X=2,Y=-2,Z=-8)
// Added by Man Chrzan: xPatch 2.0	
	WeaponSpeedShoot1  = 1.25
	WeaponSpeedShoot2  = 1.25
}
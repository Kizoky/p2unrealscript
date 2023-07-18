///////////////////////////////////////////////////////////////////////////////
// HammerWeapon
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class HammerWeapon extends BatonWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, etc.
///////////////////////////////////////////////////////////////////////////////
var() class<Actor> FPAttachmentClass;
var Actor FPAttachment;

const FP_ATTACHMENT_BONE = 'hammertime';

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/*
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	FPAttachment = spawn(FPAttachmentClass, Owner);
	
	if (FPAttachment != None)
		AttachToBone(FPAttachment, FP_ATTACHMENT_BONE);	
	else
		warn(self@"did not receive a first-person hammer attachment");
}

simulated event Destroyed()
{
	if (FPAttachment != None)
	{
		DetachFromBone(FPAttachment);
		FPAttachment.Destroy();
		FPAttachment = None;
	}

	Super.Destroyed();
}
*/
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	IncrementFlashCount();
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

	if (FRand() < 0.5)
		PlayAnim('Shoot1Down1', WeaponSpeedShoot1, 0.05);
	else
		PlayAnim('Shoot1Down2', WeaponSpeedShoot1, 0.05);
}

simulated function PlayAltFiring()
{
	IncrementFlashCount();
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(AltFireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(AltFireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

	if (FRand() < 0.5)
		PlayAnim('Shoot1Left', WeaponSpeedShoot2, 0.05);
	else
		PlayAnim('Shoot1Right', WeaponSpeedShoot2, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// xPatch 2.0
// Baton ignores DrewBlood but we want it for Hammer so use super.
///////////////////////////////////////////////////////////////////////////////
function DrewBlood()
{
	Super(P2BloodWeapon).DrewBlood();
}

// left arm fix
state Active
{
	function BeginState()
	{
		Super.BeginState();
		SetBoneScale(0, 0.0, 'Bip01 L UpperArm');
	}
}

defaultproperties
{
	ItemName="Hammer"
	FPAttachmentClass=class'HammerAttachmentFP'
	AttachmentClass=class'HammerAttachment'
	PickupClass=class'HammerPickup'
	AmmoName=class'HammerAmmoInv'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	// Change by Man Chrzan: xPatch 2.0	
	Skins[1]=Texture'HammerTex.hammer' 					//Shader'PL-KamekTex.derp.invisitex'
	Mesh=SkeletalMesh'ED_Weapons.ED_Hammer_NEW' 		//'ED_WeaponsToo.ED_Hammer'
	OverrideHUDIcon=Texture'HammerTex.hud_Hammer' 		//'PLHud.Icons.Icon_Weapon_Hammer'
	BloodTextures[0]=Texture'HammerTex.Hammer_Bloody1' 	
	BloodTextures[1]=Texture'HammerTex.Hammer_Bloody2' 
	FireSound=Sound'EDWeaponSounds.Fight.Swing1'
	AltFireSound=Sound'EDWeaponSounds.Fight.Swing2'
	GroupOffset=25
}

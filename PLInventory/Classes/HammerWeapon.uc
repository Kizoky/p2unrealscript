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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
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
		PlayAnim('Shoot2Left', WeaponSpeedShoot2, 0.05);
	else
		PlayAnim('Shoot2Right', WeaponSpeedShoot2, 0.05);
}

defaultproperties
{
	ItemName="Hammer"
	FPAttachmentClass=class'HammerAttachmentFP'
	AttachmentClass=class'HammerAttachment'
	PickupClass=class'HammerPickup'
	AmmoName=class'HammerAmmoInv'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Shader'PL-KamekTex.derp.invisitex'
	Mesh=SkeletalMesh'ED_WeaponsToo.ED_Hammer'
	OverrideHUDIcon=Texture'PLHud.Icons.Icon_Weapon_Hammer'
}

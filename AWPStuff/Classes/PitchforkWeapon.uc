///////////////////////////////////////////////////////////////////////////////
// PitchforkWeapon
// Copyright 2014, Running With Scissors, Inc.
//
// A "toy" pitchfork the Dude finds during halloween.
// It's basically the Shovel but with a different thing in his hands.
///////////////////////////////////////////////////////////////////////////////
class PitchforkWeapon extends ShovelWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars consts etc.
///////////////////////////////////////////////////////////////////////////////
var() class<Actor> FPAttachmentClass;	// First-person attachment class
var() name FPAttachmentBone;			// First-person attachment bone
var Actor FPAttachment;

///////////////////////////////////////////////////////////////////////////////
// Functions to set up and remove the thing in his hands
///////////////////////////////////////////////////////////////////////////////
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (FPAttachment == None && FPAttachmentClass != None)
	{
		FPAttachment = Spawn(FPAttachmentClass);
		AttachToBone(FPAttachment, FPAttachmentBone);
	}
}

simulated event Destroyed()
{
	if (FPAttachment != None)
	{
		FPAttachment.Destroy();
		FPAttachment = None;
	}
	
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// No blood texture
///////////////////////////////////////////////////////////////////////////////
function DrewBlood()
{
}

defaultproperties
{
	Mesh=SkeletalMesh'AW7_Weapons.LS_Pitchfork_New'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Shader'AW7Tex.Weapons.InvisiblePistol'
	FPAttachmentClass=class'PitchforkAttachmentFP'
	AttachmentClass=class'PitchforkAttachment'
	PickupClass=class'PitchforkPickup'
	OverrideHUDIcon=Texture'AW7Tex.Icons.HUD_Pitchfork_New'
	FPAttachmentBone="ShovelAttach"
	ThirdPersonRelativeLocation=(X=.25,Y=1,Z=4)
	ThirdPersonRelativeRotation=(Pitch=7700,Roll=2400,Yaw=1024)
	GroupOffset=22
	ItemName="Pitchfork"
}
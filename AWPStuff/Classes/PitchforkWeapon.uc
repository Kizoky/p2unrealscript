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

// Change by NickP: MP fix
var Texture InvisSkinTex;
// End

///////////////////////////////////////////////////////////////////////////////
// Functions to set up and remove the thing in his hands
///////////////////////////////////////////////////////////////////////////////
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Change by NickP: MP fix
	/*if (FPAttachment == None && FPAttachmentClass != None)
	{
		FPAttachment = Spawn(FPAttachmentClass);
		AttachToBone(FPAttachment, FPAttachmentBone);
	}*/
}

// Change by NickP: MP fix
simulated function AttachFPPart()
{
    local PlayerController PC;
	local Pawn P;

    P  = Pawn(Owner);
	PC = PlayerController(P.Controller);

	if( FPAttachmentClass != None && P.IsLocallyControlled() && PC != None && !PC.bBehindView )
	{
		if( FPAttachment == None )
			FPAttachment = Spawn(FPAttachmentClass,self);
		AttachToBone(FPAttachment, FPAttachmentBone);
	}

	if( FPAttachment != None && FPAttachment.AttachmentBone == '' )
		FPAttachment.Skins[0] = InvisSkinTex;
}

simulated function BringUp()
{
    Super.BringUp();
	AttachFPPart();
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
	AttachFPPart();
}

simulated function DropFrom(vector StartLocation)
{
	Super.DropFrom(StartLocation);
	if( FPAttachment != None )
	{
		DetachFromBone(FPAttachment);
		FPAttachment.Destroy();
		FPAttachment = None;
	}
}
// End

simulated event Destroyed()
{
	if (FPAttachment != None)
	{
		DetachFromBone(FPAttachment); // Change by NickP: MP fix
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
	// Change by NickP: MP fix
	InvisSkinTex=Shader'P2R_Tex_D.Weapons.fake'
	// End

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
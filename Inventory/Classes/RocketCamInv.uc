///////////////////////////////////////////////////////////////////////////////
// RocketCamInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Rocket camera inventory item.
//
// Camera that attaches to the rocket as it travels.
// This *does not* plug in to the radar. It just acts very similar to those
// plug-ins. It only requires the rocket launcher to be useful.
//
///////////////////////////////////////////////////////////////////////////////

class RocketCamInv extends GunRadarPlugInv;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Tell the player you're into the rocket cameras
///////////////////////////////////////////////////////////////////////////////
function SetPlayerVar(bool bSet)
{
	local P2Pawn CheckPawn;

	CheckPawn = P2Pawn(Owner);

	if(P2Player(CheckPawn.Controller) != None)
		P2Player(CheckPawn.Controller).bUseRocketCameras = bSet;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'RocketCamPickup'
	Icon=Texture'Hudpack.icons.Rocket_Cam_Icon'
	InventoryGroup=101
	GroupOffset=9
	PowerupName="Raimi Rocket Cam"
	PowerupDesc="Holy crap -- a camera for your rockets! Activate to toggle on or off."
	ExamineAnimType="Letter"
	ExamineDialog=Sound'DudeDialog.dude_ithinkineedthat'
	bThrowIndividually=false
	Hint1="Press %KEY_InventoryActivate% to attach cameras to any"
	Hint2="rockets you shoot."
	Hint3="Rocket Cameras are On."
	Hint4="Rocket Cameras are Off."
	ActivateSound = Sound'MiscSounds.Radar.PluginActivate'
	DeactivateSound = Sound'MiscSounds.Radar.PluginDeactivate'
	}

///////////////////////////////////////////////////////////////////////////////
// CopRadarPlugInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Plug-in for the radar. Show's 'fish' that are *authority figures* as
// having a little cop hat on their heads. Using the GunRadar plug-in with this
// *won't* show cop fish with guns. You already know they have guns, cause
// they are cops.
// 
// This is good for seeing cops on the other sides of walls.
//
// Toggle it on and off by using it.
//
///////////////////////////////////////////////////////////////////////////////

class CopRadarPlugInv extends GunRadarPlugInv;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Only code that should change with each plug-in
///////////////////////////////////////////////////////////////////////////////
function SetPlayerVar(bool bSet)
{
	local P2Pawn CheckPawn;

	CheckPawn = P2Pawn(Owner);

	if(P2Player(CheckPawn.Controller) != None)
		P2Player(CheckPawn.Controller).SetRadarShowCops(bActive);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'CopRadarPlugPickup'
	Icon=Texture'Hudpack.icons.icon_inv_Largemouth'
	InventoryGroup=101
	GroupOffset=8
	PowerupName="'Largemouth Bass' Plug-In"
	PowerupDesc="Shows the fish who police the pond on your Bass Sniffer Radar."
	ExamineAnimType="Letter"
	ExamineDialog=Sound'DudeDialog.dude_ithinkineedthat'
	Hint1="Press %KEY_InventoryActivate% when your Radar is active"
	Hint2="to see the fish who police the pond."
	Hint3="'Largemouth Bass' Plug-in is On."
	Hint4="'Largemouth Bass' Plug-in is Off."
	ActivateSound = Sound'MiscSounds.Radar.PluginActivate'
	DeactivateSound = Sound'MiscSounds.Radar.PluginDeactivate'
	}

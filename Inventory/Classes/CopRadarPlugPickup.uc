///////////////////////////////////////////////////////////////////////////////
// CopRadarPlugPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Plug-in for the radar. Show's 'fish' that are authority figures as
// having a little cop hat on their heads. Using the GunRadar plug-in with this
// *won't* show cop fish with guns. You already know they have guns, cause
// they are cops
//
///////////////////////////////////////////////////////////////////////////////

class CopRadarPlugPickup extends GunRadarPlugPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'CopRadarPlugInv'
	PickupMessage="You picked up the 'Largemouth Bass' Plug-in for BassSniffer Radar."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Josh_mesh.signs.Fish_Cartridge'
	Skins[0]=Texture'Josh-textures.Misc.Largemouth_pack'
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	}

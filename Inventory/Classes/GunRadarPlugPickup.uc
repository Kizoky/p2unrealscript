///////////////////////////////////////////////////////////////////////////////
// GunRadarPlugPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Plug-in for the radar. Show's 'fish' that are authority figures as
// having a little cop hat on their heads. Using the GunRadar plug-in with this
// *won't* show cop fish with guns. You already know they have guns, cause
// they are cops
//
///////////////////////////////////////////////////////////////////////////////

class GunRadarPlugPickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'GunRadarPlugInv'
	PickupMessage="You picked up the 'Piranha' Plug-in for BassSniffer Radar."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Josh_mesh.signs.Fish_Cartridge'
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	CollisionHeight=6.0
	}

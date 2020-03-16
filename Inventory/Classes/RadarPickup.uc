///////////////////////////////////////////////////////////////////////////////
// RadarPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Radar used to show other people right around you (through walls, terrain)
// It looks like a fish finder.
//
///////////////////////////////////////////////////////////////////////////////

class RadarPickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'RadarInv'
	PickupMessage="You picked up a Fish Finder."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Josh_mesh.signs.Bass_Sniffer'
	AmountToAdd=60
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	}

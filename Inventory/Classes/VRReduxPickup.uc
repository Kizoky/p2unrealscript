///////////////////////////////////////////////////////////////////////////////
// VRReduxPickup
// Copyright 2016 Running With Scissors, Inc.  All Rights Reserved.
//
// POSTAL Redux pickup.
//
//
///////////////////////////////////////////////////////////////////////////////

class VRReduxPickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'VRReduxInv'
	PickupMessage="You received POSTAL Redux, available for purchase now in the real world!"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ReopeningJune2016MOD.Obj.DiscBox01AMod'
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	DrawScale=2.4
	}

///////////////////////////////////////////////////////////////////////////////
// MoneyPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Money pickup.
//
//	If it's been dropped by the dude, it can lure greedy people to it.
// They will bend down and take it, if they notice it.
//
///////////////////////////////////////////////////////////////////////////////

class MoneyPickup extends OwnedPickup;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'MoneyInv'
	PickupMessage="You picked up some Money."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Money'
	AmountToAdd=10
	DesireMarkerClass=class'MoneyMarker'
	bBreaksWindows=false
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	}

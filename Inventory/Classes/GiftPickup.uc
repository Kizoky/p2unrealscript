///////////////////////////////////////////////////////////////////////////////
// GiftPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Gift pickup.
//
//
///////////////////////////////////////////////////////////////////////////////

class GiftPickup extends KrotchyPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	Price=0
	InventoryType=class'GiftInv'
	PickupMessage="You picked up your Gift for Uncle Dave."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Gift'
	bPaidFor=false
	LegalOwnerTag="UncleDave"
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	}

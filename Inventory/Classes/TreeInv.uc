///////////////////////////////////////////////////////////////////////////////
// TreeInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Christmas tree inventory item.
// (it's a really small tree)
//
///////////////////////////////////////////////////////////////////////////////

class TreeInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'TreePickup'
	Icon=Texture'nathans.Inventory.TreeInv'
	InventoryGroup=102
	GroupOffset=6
	PowerupName="Christmas Tree"
	PowerupDesc="The little tree that could."
	bCanThrow=false
	Price=0
	bPaidFor=true
	LegalOwnerTag=""
	UseForErrands=1
	}

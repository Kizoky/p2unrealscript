///////////////////////////////////////////////////////////////////////////////
// GaryBookInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Gary book inventory item.
//
///////////////////////////////////////////////////////////////////////////////

class GaryBookInv extends BookInv;

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
Begin:
	CheckToGiveToInterest();
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'GaryBookPickup'
	Icon=Texture'HUDPack.Icon_Inv_GaryBook'
	InventoryGroup=102
	GroupOffset=5
	PowerupName="Gary Coleman's Autobiography"
	PowerupDesc="Maybe someone's actually interested in this?"
	Price=0
	bPaidFor=true
	LegalOwnerTag=None
	UseForErrands=1
	Hint1=""
	Hint2=""
	Hint3=""
	bUsePaidHints=false
	}

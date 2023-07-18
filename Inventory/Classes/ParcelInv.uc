///////////////////////////////////////////////////////////////////////////////
// ParcelInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Parcel inventory item.
//
///////////////////////////////////////////////////////////////////////////////

class ParcelInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	/*
	function UseIt()
	{
		local P2Pawn CheckPawn;

		CheckPawn = P2Pawn(Owner);

		if(CheckPawn.CureGonorrhea())
		{
		}
		ReduceAmount(1);
	}
Begin:
	UseIt();
	GotoState('');
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'ParcelPickup'
	Icon=Texture'HUDPack.Icons.Icon_Inv_Package'
	InventoryGroup=102
	GroupOffset=12
	PowerupName="Package"
	PowerupDesc="It seems to be making ticking sounds..."
	Price=20
	bPaidFor=true
	LegalOwnerTag="Lucy"
	UseForErrands=1
	}
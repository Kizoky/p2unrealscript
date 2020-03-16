///////////////////////////////////////////////////////////////////////////////
// PillsInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Pills inventory item.
//
///////////////////////////////////////////////////////////////////////////////

class PillsInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	function UseIt()
	{
		local P2Pawn CheckPawn;

		CheckPawn = P2Pawn(Owner);

		TurnOffHints();	// When you use it, turn off the hints

		if(CheckPawn.CureGonorrhea())
		{
		}
		ReduceAmount(1);
	}
Begin:
	UseIt();
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'PillsPickup'
	Icon=Texture'HUDpack.icons.Icon_Inv_Penicillin'
	InventoryGroup=102
	GroupOffset=13
	PowerupName="Pills"
	PowerupDesc="Label reads: 'Cures gonorrhea fast!'"
	Price=0
	bPaidFor=true
	LegalOwnerTag=""
	UseForErrands=1
	Hint1="Label reads:"
	Hint2="'Cures gonorrhea fast!'"
	}

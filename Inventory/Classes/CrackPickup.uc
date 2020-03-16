///////////////////////////////////////////////////////////////////////////////
// CrackPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Crack pickup.
//
//
///////////////////////////////////////////////////////////////////////////////

class CrackPickup extends P2PowerupPickup;

///////////////////////////////////////////////////////////////////////////////
// Pickup state: this inventory item is sitting on the ground.
///////////////////////////////////////////////////////////////////////////////
state Pickup
{
	///////////////////////////////////////////////////////////////////////////////
	// ValidTouch()
	// Validate touch (if valid return true to let other pick me up and trigger event).
	//
	///////////////////////////////////////////////////////////////////////////////
	function bool ValidTouch( actor Other )
	{
		// In nightmare mode don't pick up the item unless you really need it.
		if (P2GameInfo(Level.Game).InNightmareMode()
			&& P2Pawn(Other) != None
			&& P2Pawn(Other).Health >= P2Pawn(Other).HealthMax)
			return false;
		else
			return Super.ValidTouch(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'CrackInv'
	NightmareInventoryType=class'MedKitInv'
	PickupMessage="You picked up a Health Pipe."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.CrackPipe'
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	bNoBotPickup=true
	MaxDesireability = -1.0
	}

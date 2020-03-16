///////////////////////////////////////////////////////////////////////////////
// FastFoodPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A tastey, fatty, bag of fast food
//
///////////////////////////////////////////////////////////////////////////////

class FastFoodPickup extends OwnedPickup;

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
		//log(self@"valid touch check"@P2GameInfo(Level.Game).InNightmareMode()@P2Pawn(Other) != None@P2Pawn(Other).Health >= P2Pawn(Other).HealthMax@!bUseForErrands);
		// In nightmare mode don't pick up the item unless you really need it.
		if (P2GameInfo(Level.Game).InNightmareMode()
			&& P2Pawn(Other) != None
			&& P2Pawn(Other).Health >= P2Pawn(Other).HealthMax
			&& !bUseForErrands)
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
	InventoryType=class'FastFoodInv'
	NightmareInventoryType=class'FastFoodInvAuto'
	PickupMessage="You picked up a bag of Fast Food."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.food'

	bEdible=true
	DesireMarkerClass=class'OtherFoodMarker'
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	bNoBotPickup=true
	MaxDesireability = -1.0
	}

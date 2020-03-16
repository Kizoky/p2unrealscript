///////////////////////////////////////////////////////////////////////////////
// ClipboardPickup
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Collection can weapon pickup.
//
///////////////////////////////////////////////////////////////////////////////

class ClipboardPickup extends P2WeaponPickup;

var ()bool bMoneyGoesToCharity;		// Defaults true. This means the money goes to an errand and
									// not to your wallet.

///////////////////////////////////////////////////////////////////////////////
// PreTravel so the clipboard can magic itself back into the Dude's inventory
///////////////////////////////////////////////////////////////////////////////
function PreTravel(Pawn Other)
{
	local Inventory Copy;
	// If the dude left us behind, force ourself into their inventory anyway.
	Copy = SpawnCopy(Other);
	Copy.PickupFunction(Other);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'ClipboardWeapon'
	PickupMessage="You picked up a Clipboard."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Clipboard'
	bMoneyGoesToCharity=true
	}

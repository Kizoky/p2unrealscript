///////////////////////////////////////////////////////////////////////////////
// P2WeaponPickupErrand
//
// This is specifically for weapon pickups that trigger errand completions (like the napalm in Thursday)
//
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
class P2WeaponPickupErrand extends P2WeaponPickup
	abstract;

///////////////////////////////////////////////////////////////////////////////
// vars, const
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Spawn a new weapon for SpawnCopy, but only if Other doesn't already
// have one. If he does, then just pass that one along.
///////////////////////////////////////////////////////////////////////////////
function GetCopy(pawn Other, out Inventory Copy)
{
	Copy = Other.FindInventoryType(InventoryType);
	if(Copy == None)
		Copy = spawn(InventoryType,Other,,,rot(0,0,0));
}

///////////////////////////////////////////////////////////////////////////////
// First hit of this type, so add in what we've found
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;
	local P2GameInfoSingle checkg;

	Copy = Super.SpawnCopy(Other);

	// See if this item is in an uncompleted errand
	checkg = P2GameInfoSingle(Level.Game);
	if(checkg != None)
		checkg.CheckForErrandCompletion(self, None, Other, P2Player(Other.Controller), false);

	return Copy;
}

defaultproperties
{
}
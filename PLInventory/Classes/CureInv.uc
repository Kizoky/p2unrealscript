///////////////////////////////////////////////////////////////////////////////
// CureInv
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Unprocessed Ensmallen Cure chemicals. This is the "raw" form of the cure,
// before Gary adds the secret ingredient. Thus, it's an inventory item,
// and not a weapon yet.
///////////////////////////////////////////////////////////////////////////////
class CureInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PickupClass=class'CurePickup'
	Icon=Texture'MrD_PL_Tex.HUD.Needle_HUD'
	UseForErrands=1
	Hint1="Get this back to Big McWillis."
	bAllowHints=true
	bCanThrow=false
	InventoryGroup=102
	GroupOffset=19
	PowerupName="Cure Chemicals"
	PowerupDesc="Get these back to Big McWillis."
}

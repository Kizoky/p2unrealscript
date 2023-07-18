///////////////////////////////////////////////////////////////////////////////
// AWNukeInv
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Nuclear warhead inventory item.
//
///////////////////////////////////////////////////////////////////////////////

class AWNukeInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     bPaidFor=True
     bCanThrow=False
     UseForErrands=1
	InventoryGroup=102
	GroupOffset=14
	PowerupName="Nuclear Warhead"
	PowerupDesc="Guaranteed to make a nice fireball."
     PickupClass=Class'AWInventory.AWNukePickup'
     Icon=Texture'AW_Textures.Nuke_Icon'
}
///////////////////////////////////////////////////////////////////////////////
// MilkInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Milk inventory item.
//
//	History:
//		03/19/02 NPF	Started history, probably won't be updated again until
//							the pace of change slows down.
//
///////////////////////////////////////////////////////////////////////////////

class MilkInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'MilkPickup'
	Icon=Texture'nathans.Inventory.MilkInv'
	InventoryGroup=102
	GroupOffset=2
	PowerupName="Milk"
	PowerupDesc="...'Jihad' Goat Milk?"
	bCanThrow=false
	}
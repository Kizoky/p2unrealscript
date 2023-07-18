///////////////////////////////////////////////////////////////////////////////
// AlternatorInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Alternator inventory item.
//
///////////////////////////////////////////////////////////////////////////////

class AlternatorInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'AlternatorPickup'
	Icon=Texture'HUDPack.Icon_Inv_Alternator'
	InventoryGroup=102
	GroupOffset=10
	PowerupName="Alternator"
	PowerupDesc="For an '87 DaFuQue"
	Price=400
	bPaidFor=true
	LegalOwnerTag="JunkyardGuy"
	UseForErrands=1
	}
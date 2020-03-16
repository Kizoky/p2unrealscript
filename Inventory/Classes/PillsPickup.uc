///////////////////////////////////////////////////////////////////////////////
// PillsPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Pills pickup.
//
//
///////////////////////////////////////////////////////////////////////////////

class PillsPickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'PillsInv'
	PickupMessage="You picked up some Gonorrhea medicine."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Penicillin'
	bPaidFor=true
	Price=0
	LegalOwnerTag=""
	bUseForErrands=true
	bBreaksWindows=false
	bAllowMovement=false
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	}

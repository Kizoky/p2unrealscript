///////////////////////////////////////////////////////////////////////////////
// CitationPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Citation pickup.
//
///////////////////////////////////////////////////////////////////////////////

class CitationPickup extends BookPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'CitationInv'
	PickupMessage="You picked up your Traffic Citation."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Stuff.stuff1.Citation'
	Price=300
	bPaidFor=false
	LegalOwnerTag="Dick"
	bUseForErrands=true
	bBreaksWindows=false
	bAllowMovement=false
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	}

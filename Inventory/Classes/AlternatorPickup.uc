///////////////////////////////////////////////////////////////////////////////
// AlternatorPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Alternator pickup.
//
//
///////////////////////////////////////////////////////////////////////////////

class AlternatorPickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'AlternatorInv'
	PickupMessage="You picked up a Car Alternator."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Stuff.stuff1.alternator'
	bPaidFor=true
	Price=400
	LegalOwnerTag="JunkyardGuy"
	bUseForErrands=true
	bAllowMovement=false
	}
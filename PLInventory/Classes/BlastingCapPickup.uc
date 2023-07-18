///////////////////////////////////////////////////////////////////////////////
// Blasting Cap Pickup
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Blasting cap errand item
///////////////////////////////////////////////////////////////////////////////
class BlastingCapPickup extends OwnedPickup;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	InventoryType=class'BlastingCapInv'
	PickupMessage="You picked up a blasting cap."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PL_tylermesh2.BlastingCAP.c4_detonator'
//	UseForErrands=1
}

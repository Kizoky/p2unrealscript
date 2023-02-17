///////////////////////////////////////////////////////////////////////////////
// ACPartPickup
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Various parts for a busted air conditioner.
///////////////////////////////////////////////////////////////////////////////
class ACPartPickup extends OwnedPickup;

///////////////////////////////////////////////////////////////////////////////
// Reduce the amount of the inventory we just got generated from
///////////////////////////////////////////////////////////////////////////////
function TakeAmountFromInv(P2PowerupInv p2Inv, int amounttoremove)
{
	local StaticMesh newmesh;
	local int IsTainted;

	// Take some from it and use this static mesh
	p2Inv.ReduceAmount(amounttoremove,,newmesh, IsTainted, true);

	// Set our mesh from whoever dropped us
	SetStaticMesh(newmesh);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	InventoryType=class'ACPartInv'
	PickupMessage="You picked up some air conditioning parts."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PLPickupMesh.aircon.ac_motor'
	DrawScale=1
	bUseForErrands=True
}

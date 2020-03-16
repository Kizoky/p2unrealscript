///////////////////////////////////////////////////////////////////////////////
// TreePickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Christmas tree pickup. It's a pretty small tree.
//
///////////////////////////////////////////////////////////////////////////////

class TreePickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'TreeInv'
	PickupMessage="You picked up a Christmas Tree."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Timb_mesh.street.x-mas_tree'
	bPaidFor=true
	Price=0
	LegalOwnerTag=""
	CollisionRadius=30
	CollisionHeight=30
	bUseForErrands=true
	bAllowMovement=false
	}

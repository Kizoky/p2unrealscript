///////////////////////////////////////////////////////////////////////////////
// MilkPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Milk pickup.
//
//	History:
//		03/19/02 NPF	Started history, probably won't be updated again until
//							the pace of change slows down.
//
///////////////////////////////////////////////////////////////////////////////

class MilkPickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	Price=5
	InventoryType=class'MilkInv'
	PickupMessage="You picked up a carton of Milk."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.MilkCarton'
	bAllowMovement=false
	CollisionHeight=20.0
	}

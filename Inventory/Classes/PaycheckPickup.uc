///////////////////////////////////////////////////////////////////////////////
// PaycheckPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Paycheck pickup.
//
//
///////////////////////////////////////////////////////////////////////////////

class PaycheckPickup extends OwnedPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	Price=150
	InventoryType=class'PaycheckInv'
	PickupMessage="You picked up your Paycheck."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Timb_mesh.Items.paycheck'
	bPaidFor=false
	LegalOwnerTag="jenny"
	bUseForErrands=true
	CollisionRadius=40.000000
	CollisionHeight=30.000000
	bBreaksWindows=false
	bAllowMovement=false
	}

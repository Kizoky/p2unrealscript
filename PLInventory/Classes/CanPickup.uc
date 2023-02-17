///////////////////////////////////////////////////////////////////////////////
// CanPickup
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Collection can weapon pickup.
///////////////////////////////////////////////////////////////////////////////
class CanPickup extends P2WeaponPickup;

var ()bool bMoneyGoesToCharity;		// Defaults true. This means the money goes to an errand and
									// not to your wallet.

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	InventoryType=class'CanWeapon'
	PickupMessage="You picked up a Collection Can."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.OldTinCup_D'
	bMoneyGoesToCharity=true
}

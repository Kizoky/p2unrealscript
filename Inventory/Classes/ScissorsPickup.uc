///////////////////////////////////////////////////////////////////////////////
// ScissorsPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ScissorsPickup extends P2DualWieldWeaponPickup;

defaultproperties
	{
	AmmoGiveCount=12
	MPAmmoGiveCount=12
	DeadNPCAmmoGiveRange=(Min=2,Max=10)
	InventoryType=class'ScissorsWeapon'
	ShortSleeveType=class'ScissorsWeaponSS'
	PickupMessage="You picked up some Scissors."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.scissorsbox'
	CollisionRadius=30.000000
	CollisionHeight=30.000000
	MaxDesireability = 0.65
	}
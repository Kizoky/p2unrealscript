//=============================================================================
// PistolPickup
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Pistol weapon pickup.
//
//	History:
//		01/29/02 MJR	Started history, probably won't be updated again until
//							the pace of change slows down.
//
//=============================================================================

class PistolPickup extends P2DualWieldWeaponPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	AmmoGiveCount=9
	MPAmmoGiveCount=20
	DeadNPCAmmoGiveRange=(Min=2,Max=5)
	InventoryType=class'PistolWeapon'
	ShortSleeveType=class'PistolWeaponSS'
	PickupMessage="You picked up a Pistol."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.pistol'
	CollisionRadius=40.000000
	CollisionHeight=5.000000
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	}

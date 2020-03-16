///////////////////////////////////////////////////////////////////////////////
// GrenadePickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class GrenadePickup extends P2WeaponPickup;

defaultproperties
	{
	AmmoGiveCount=4
	MPAmmoGiveCount=4
	DeadNPCAmmoGiveRange=(Min=1,Max=1)
	InventoryType=class'GrenadeWeapon'
	ShortSleeveType=class'GrenadeWeaponSS'
	PickupMessage="You picked up some Grenades."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.grenade'
	CollisionRadius=35.000000
	CollisionHeight=20.000000
	BounceSound=Sound'WeaponSounds.grenade_bounce'
	bNoBotPickup=true
	MaxDesireability = -1.0
	}
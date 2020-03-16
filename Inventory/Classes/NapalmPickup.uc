///////////////////////////////////////////////////////////////////////////////
// NapalmPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class NapalmPickup extends P2WeaponPickup;

defaultproperties
	{
	AmmoGiveCount=3
	MPAmmoGiveCount=3
	DeadNPCAmmoGiveRange=(Min=1,Max=3)
	InventoryType=class'NapalmWeapon'
	PickupMessage="You picked up a Napalm Cannister Launcher."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.napalmgun'
	CollisionRadius=60.000000
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	}
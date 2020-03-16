///////////////////////////////////////////////////////////////////////////////
// LauncherPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class LauncherPickup extends P2DualWieldWeaponPickup;

defaultproperties
	{
	AmmoGiveCount=100
	MPAmmoGiveCount=35
	DeadNPCAmmoGiveRange=(Min=10,Max=100)
	InventoryType=class'LauncherWeapon'
	ShortSleeveType=class'LauncherWeaponSS'
	PickupMessage="You picked up a Rocket Launcher."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Launcher'
	CollisionRadius=60.000000
	CollisionHeight=20.000000
	BounceSound=Sound'MiscSounds.Props.MetalCrateDoor'
	bNoBotPickup=true
	MaxDesireability = -1.0
	}
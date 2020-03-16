///////////////////////////////////////////////////////////////////////////////
// MolotovPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class MolotovPickup extends P2WeaponPickup;

defaultproperties
	{
	AmmoGiveCount=1
	MPAmmoGiveCount=1
	DeadNPCAmmoGiveRange=(Min=1,Max=1)
	InventoryType=class'MolotovWeapon'
	ShortSleeveType=class'MolotovWeaponSS'
	PickupMessage="You picked up a Molotov Cocktail."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.molotov'
	CollisionRadius=35.000000
	CollisionHeight=20.000000
	bNoBotPickup=true
	MaxDesireability = -1.0
	}
///////////////////////////////////////////////////////////////////////////////
// CowHeadPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class CowHeadPickup extends P2WeaponPickup;

defaultproperties
	{
	AmmoGiveCount=1
	MPAmmoGiveCount=1
	DeadNPCAmmoGiveRange=(Min=1,Max=1)
	InventoryType=class'CowHeadWeapon'
	ShortSleeveType=class'CowHeadWeaponSS'
	PickupMessage="You picked up a diseased Cow Head."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.cowhead'
	CollisionHeight=25.000000
	BounceSound=Sound'WeaponSounds.cowhead_bounce'
	bNoBotPickup=true
	MaxDesireability = -1.0
	}
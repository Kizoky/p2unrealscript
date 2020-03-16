///////////////////////////////////////////////////////////////////////////////
// GrenadePickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class GSelectPickup extends P2DualWieldWeaponPickup;

defaultproperties
{
	AmmoGiveCount=9
	MPAmmoGiveCount=20
	DeadNPCAmmoGiveRange=(Min=2,Max=5)
	InventoryType=class'GSelectWeapon'
	PickupMessage="You picked up a Glock."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.WeaponPickups.PU_Glock'
	CollisionRadius=40.000000
	CollisionHeight=5.000000
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
}

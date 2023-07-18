///////////////////////////////////////////////////////////////////////////////
// GrenadePickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class GSelectPickup extends P2DualWieldWeaponPickup;

defaultproperties
{
	AmmoGiveCount=20 //9
	MPAmmoGiveCount=20
	DeadNPCAmmoGiveRange=(Min=10,Max=20)
	InventoryType=class'GSelectWeapon'
	PickupMessage="You picked up a Machine Pistol."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.WeaponPickups.PU_Glock'
	CollisionRadius=40.000000
	CollisionHeight=5.000000
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
}

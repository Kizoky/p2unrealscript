class MP5Pickup extends P2DualWieldWeaponPickup;

defaultproperties
{
	AmmoGiveCount=30
	DeadNPCAmmoGiveRange=(Min=10,Max=25)
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	MPAmmoGiveCount=30
	InventoryType=Class'MP5Weapon'
	PickupMessage="You picked up a Submachine Gun."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.WeaponPickups.PU_MP5'
}

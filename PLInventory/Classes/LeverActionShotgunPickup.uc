class LeverActionShotgunPickup extends P2DualWieldWeaponPickup;

defaultproperties
{
    AmmoGiveCount=5
	MPAmmoGiveCount=5
	DeadNPCAmmoGiveRange=(Min=1,Max=5)
	InventoryType=class'LeverActionShotgunWeapon'
	ShortSleeveType=class'LeverActionShotgunWeapon'
	PickupMessage="You picked up a Lever Action Shotgun."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PL_Weapons_Mesh.1887.PU_1887'
	BounceSound=sound'MiscSounds.PickupSounds.gun_bounce'
}
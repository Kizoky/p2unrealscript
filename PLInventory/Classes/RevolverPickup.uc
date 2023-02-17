/**
 * RevolverPickup
 */
class RevolverPickup extends P2DualWieldWeaponPickup;

defaultproperties
{
	AmmoGiveCount=6
	MPAmmoGiveCount=20
	DeadNPCAmmoGiveRange=(Min=2,Max=5)
	InventoryType=class'RevolverWeapon'
	ShortSleeveType=class'RevolverWeapon'
	PickupMessage="You picked up a Revolver"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PLPickupMesh.Weapons.PU_Revolver'
	CollisionRadius=40
	CollisionHeight=5
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	DrawScale=1.0
}

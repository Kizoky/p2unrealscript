class ShotGunPickup extends P2WeaponPickup;

defaultproperties
	{
	AmmoGiveCount=8
	MPAmmoGiveCount=8
	DeadNPCAmmoGiveRange=(Min=2,Max=5)
	InventoryType=class'ShotGunWeapon'
	ShortSleeveType=class'ShotGunWeaponSS'
	PickupMessage="You picked up a Shotgun."
//	PickupSound=Sound'WeaponPickup'
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.shotgun'
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	MaxDesireability = 0.7
	}
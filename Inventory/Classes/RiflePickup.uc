class RiflePickup extends P2WeaponPickup;

defaultproperties
	{
	AmmoGiveCount=5
	MPAmmoGiveCount=3
	DeadNPCAmmoGiveRange=(Min=1,Max=4)
	InventoryType=class'RifleWeapon'
	ShortSleeveType=class'RifleWeaponSS'
	PickupMessage="You picked up a Hunting Rifle."
//	PickupSound=Sound'WeaponPickup'
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.sniper'
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	}
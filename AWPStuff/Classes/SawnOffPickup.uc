class SawnOffPickup extends P2WeaponPickup;

defaultproperties
{
	DeadNPCAmmoGiveRange=(Min=1.000000,Max=4.000000)
	AmmoGiveCount=12
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	MPAmmoGiveCount=4
	MaxDesireability=0.700000
	InventoryType=Class'SawnOffWeapon'
	PickupMessage="You picked up a sawed-off shotgun."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'AW7EDMesh.Weapons.PU_SawnOff'
}


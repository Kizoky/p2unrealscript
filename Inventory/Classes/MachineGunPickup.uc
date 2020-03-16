class MachineGunPickup extends P2DualWieldWeaponPickup;

defaultproperties
	{
	AmmoGiveCount=35
	MPAmmoGiveCount=35
	DeadNPCAmmoGiveRange=(Min=10,Max=25)
	InventoryType=class'MachineGunWeapon'
	ShortSleeveType=class'MachineGunWeaponSS'
	PickupMessage="You picked up a Machine Gun."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.machinegun'
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	}
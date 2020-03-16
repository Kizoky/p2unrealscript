class ShovelPickup extends P2WeaponPickup;

defaultproperties
	{
	InventoryType=class'ShovelWeapon'
	ShortSleeveType=class'ShovelWeaponSS'
	PickupMessage="You picked up a Shovel."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.shovel'
	BounceSound=Sound'MiscSounds.PickupSounds.woodhitsground1'
	}
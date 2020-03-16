class BatonPickup extends P2WeaponPickup;

defaultproperties
	{
	RelativeRotation=(Roll=16383)
	InventoryType=class'BatonWeapon'
	ShortSleeveType=class'BatonWeaponSS'
	PickupMessage="You picked up a Police Baton."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Baton'
	BounceSound=Sound'MiscSounds.PickupSounds.woodhitsground1'
	}
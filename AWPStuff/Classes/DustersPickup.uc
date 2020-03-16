class DustersPickup extends P2WeaponPickup;

defaultproperties
	{
	RelativeRotation=(Roll=16383)
	InventoryType=class'DustersWeapon'
//	ShortSleeveType=class'DustersWeaponSS'
	PickupMessage="You picked up a set of knuckle dusters."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'AW7EDMesh.Weapons.PU_Dusters'
	BounceSound=Sound'MiscSounds.PickupSounds.woodhitsground1'
	}

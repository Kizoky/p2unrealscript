class BaseballBatPickup extends P2WeaponPickup;

defaultproperties
{
	StaticMesh=StaticMesh'AW7EDMesh.Weapons.PU_BaseballBat'
	Skins[0]=Texture'ED_WeaponSkins.Melee.WoodenBat'
	InventoryType=class'BaseballBatWeapon'
	ShortSleeveType=class'BaseballBatWeapon'
	PickupMessage="You picked up a Baseball Bat."
	DrawType=DT_StaticMesh
	BounceSound=Sound'MiscSounds.PickupSounds.woodhitsground1'
}
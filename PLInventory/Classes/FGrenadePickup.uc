class FGrenadePickup extends P2WeaponPickup;

defaultproperties
	{
	AmmoGiveCount=4
	MPAmmoGiveCount=4
	DeadNPCAmmoGiveRange=(Min=1,Max=1)
	InventoryType=class'FGrenadeWeapon'
	//ShortSleeveType=class'GrenadeWeaponSS'
	PickupMessage="You picked up some Flash Grenades."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.Flash_Nade' //Change
	CollisionRadius=35.000000
	CollisionHeight=20.000000
	BounceSound=Sound'PL_FlashGrenadeSound.FlashGrenade_Bounce'
	bNoBotPickup=true
	MaxDesireability = -1.0
	}
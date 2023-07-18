class AWPGrenadeLauncherPickup extends P2WeaponPickup;

defaultproperties
{
     AmmoGiveCount=16
     DeadNPCAmmoGiveRange=(Max=10.000000)
     BounceSound=Sound'MiscSounds.Doors.MetalCrateDoor'
     MPAmmoGiveCount=8
     ShortSleeveType=Class'AWPGrenadeLauncherWeapon'
     InventoryType=Class'AWPGrenadeLauncherWeapon'
     RespawnTime=60.000000
     PickupMessage="You picked up a Semi-Automatic Grenade Launcher!"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'stuff.stuff1.Launcher'
     CollisionRadius=60.000000
     CollisionHeight=20.000000
	 Skins(0)=Texture'AW7Tex.Weapons.GrenadeLauncher'
	 Skins(1)=Shader'xPatchTex.Weapons.fuel_gauge_empty_unit'
}

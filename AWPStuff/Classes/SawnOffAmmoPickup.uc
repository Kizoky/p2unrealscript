class SawnOffAmmoPickup extends P2AmmoPickup;

defaultproperties
{
     MPAmmoAmount=10
     AmmoAmount=20
     //InventoryType=Class'SawnOffAmmoInv'		// Not used
	 InventoryType=Class'ShotGunBulletAmmoInv'	
     PickupMessage="You found some shells for a sawed-off shotgun."
     StaticMesh=StaticMesh'AW7EDMesh.Weapons.Shell_Box'
     //Skins(0)=Texture'AW7Tex.Weapons.ShellBox'
     DrawScale=2.000000
}

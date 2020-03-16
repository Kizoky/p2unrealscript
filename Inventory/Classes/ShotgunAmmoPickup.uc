///////////////////////////////////////////////////////////////////////////////
// ShotgunAmmoPickup
//
///////////////////////////////////////////////////////////////////////////////
class ShotgunAmmoPickup extends P2AmmoPickup;

defaultproperties
{
	InventoryType=class'ShotgunBulletAmmoInv'
    AmmoAmount=12
    MPAmmoAmount=12
	DrawScale=2.0
    PickupMessage="You found a box of Shotgun shells."
    StaticMesh=StaticMesh'stuff.stuff1.ShotgunAmmo'
}

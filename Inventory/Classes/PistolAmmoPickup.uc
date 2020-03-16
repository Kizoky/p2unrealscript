///////////////////////////////////////////////////////////////////////////////
// PistolAmmoPickup
//
///////////////////////////////////////////////////////////////////////////////
class PistolAmmoPickup extends P2AmmoPickup;

defaultproperties
{
	InventoryType=class'PistolBulletAmmoInv'
    AmmoAmount=20
    MPAmmoAmount=20
	DrawScale=2.0
    PickupMessage="You found a clip of Pistol rounds."
    StaticMesh=StaticMesh'stuff.stuff1.PistolAmmo'
}

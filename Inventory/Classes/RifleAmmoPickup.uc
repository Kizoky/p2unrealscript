///////////////////////////////////////////////////////////////////////////////
// RifleAmmoPickup
//
///////////////////////////////////////////////////////////////////////////////
class RifleAmmoPickup extends P2AmmoPickup;

defaultproperties
{
	InventoryType=class'RifleAmmoInv'
    AmmoAmount=7
    MPAmmoAmount=7
	DrawScale=2.0
    PickupMessage="You got some Rifle rounds."
    StaticMesh=StaticMesh'stuff.stuff1.RifleAmmo'
}

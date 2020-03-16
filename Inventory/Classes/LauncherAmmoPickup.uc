///////////////////////////////////////////////////////////////////////////////
// LauncherAmmoPickup
//
///////////////////////////////////////////////////////////////////////////////
class LauncherAmmoPickup extends P2AmmoPickup;

defaultproperties
{
	InventoryType=class'LauncherAmmoInv'
    AmmoAmount=50
    MPAmmoAmount=25
    PickupMessage="You got some Rocket launcher fuel."
    StaticMesh=StaticMesh'stuff.stuff1.LauncherAmmo'
}

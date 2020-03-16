///////////////////////////////////////////////////////////////////////////////
// PlagueAmmoPickup
//
///////////////////////////////////////////////////////////////////////////////
class PlagueAmmoPickup extends P2AmmoPickup;

defaultproperties
{
	InventoryType=class'PlagueAmmoInv'
    AmmoAmount=1
    MPAmmoAmount=1
    PickupMessage="You got some WMD Rockets."
	StaticMesh=StaticMesh'Patch1_mesh.Weapons.WMD_Ammo'
}

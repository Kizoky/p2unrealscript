///////////////////////////////////////////////////////////////////////////////
// MachinegunAmmoPickup
//
///////////////////////////////////////////////////////////////////////////////
class MachinegunAmmoPickup extends P2AmmoPickup;

defaultproperties
{
	InventoryType=class'MachinegunBulletAmmoInv'
    AmmoAmount=25
    MPAmmoAmount=25
	DrawScale=2.0
    PickupMessage="You got a clip of Machinegun rounds."
    StaticMesh=StaticMesh'stuff.stuff1.MachinegunAmmo'
}

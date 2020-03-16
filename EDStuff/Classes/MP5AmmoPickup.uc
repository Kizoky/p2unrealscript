///////////////////////////////////////////////////////////////////////////////
// MachinegunAmmoPickup
//
///////////////////////////////////////////////////////////////////////////////
class MP5AmmoPickup extends P2AmmoPickup;

defaultproperties
{
	InventoryType=class'MP5AmmoInv'
    AmmoAmount=25
    MPAmmoAmount=25
	DrawScale=2.0
    PickupMessage="You got a clip of MP5 rounds."
    StaticMesh=StaticMesh'ED_TPMeshes.AmmoPickup.MP5_Clip'
}

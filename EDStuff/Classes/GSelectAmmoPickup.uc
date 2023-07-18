///////////////////////////////////////////////////////////////////////////////
// RifleAmmoPickup
//
///////////////////////////////////////////////////////////////////////////////
class GSelectAmmoPickup extends P2AmmoPickup;

defaultproperties
{
     AmmoAmount=20 //16
     InventoryType=class'NineAmmoInv'  //Class'GSelectAmmoInv'
     PickupMessage="You found a Machine Pistol Clip."
     StaticMesh=StaticMesh'ED_TPMeshes.AmmoPickup.Glock_Clip'
	 DrawScale=1.5
}

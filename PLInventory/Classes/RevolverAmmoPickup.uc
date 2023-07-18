///////////////////////////////////////////////////////////////////////////////
// RevolverAmmoPickup
// Copyright 2014, Running With Scissors Inc. All Rights Reserved
//
// Revolver ammo
///////////////////////////////////////////////////////////////////////////////
class RevolverAmmoPickup extends P2AmmoPickup;

defaultproperties
{
	InventoryType=class'RevolverAmmoInv'
    AmmoAmount=12
    MPAmmoAmount=6
	DrawScale=1.0
    PickupMessage="You found a revolver speedloader."
    StaticMesh=StaticMesh'PLPickupMesh.Weapons.RevolverAmmoPickup'
}

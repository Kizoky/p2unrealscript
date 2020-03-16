//=============================================================
//   Butterfly Knife Pickup
//   Eternal Damnation
//   Dopamine
//=============================================================

class BaliPickup extends P2WeaponPickup;

defaultproperties
{
     BounceSound=Sound'MiscSounds.Props.woodhitsground1'
     InventoryType=Class'BaliWeapon'
     PickupMessage="You picked up a Bali."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ED_TPMeshes.WeaponPickups.PU_Bali'
}

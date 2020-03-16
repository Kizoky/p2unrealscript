//=============================================================
//   Hedge Clippers Pickup
//   Eternal Damnation
//   Dopamine|Silent-Scope
//=============================================================

class ShearsPickup extends P2WeaponPickup;

defaultproperties
{
     BounceSound=Sound'MiscSounds.Props.woodhitsground1'
     InventoryType=Class'ShearsWeapon'
     PickupMessage="You picked up a set of Hedge Clippers."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ED_TPMeshes.WeaponPickups.PU_Hedgeclippers'
}

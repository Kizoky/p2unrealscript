///////////////////////////////////////////////////////////////////////////////
// FlamePickup
// By: Kamek (kamek@postalleague.com)
// For: Eternal Damnation
//
// Pickup for the flamethrower.
// Currently using the "RWS Ozone Spray" aerosol can. I recommend we use this
// as the third person actor and re-skin the can using that "Stynx" stuff.
// The tazer third person anims work pretty well for the can here.
///////////////////////////////////////////////////////////////////////////////

class FlamePickup extends P2WeaponPickup;

defaultproperties
{
	AmmoGiveCount=100 // edit as desired
	MPAmmoGiveCount=100 // edit as desired
	InventoryType=class'FlameWeapon'
	PickupMessage="You picked up a can of Stynx."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.WeaponsPickups.PU_Flamethrower'
	DeadNPCAmmoGiveRange=(Min=10.000000,Max=80.000000)
}


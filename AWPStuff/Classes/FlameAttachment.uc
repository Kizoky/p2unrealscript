///////////////////////////////////////////////////////////////////////////////
// FlameAttachment
// By: Kamek (kamek@postalleague.com)
// For: Eternal Damnation
//
// Weapon attachment for the flamethrower.
// Currently using the "RWS Ozone Spray" aerosol can. I recommend we use this
// as the third person actor and re-skin the can using that "Stynx" stuff.
// The tazer third person anims work pretty well for the can here.
///////////////////////////////////////////////////////////////////////////////

class FlameAttachment extends P2WeaponAttachment;

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.Weapons.TP_Flamethrower'
	FiringMode="SHOCKER1"
	WeapClass=class'FlameWeapon'
}

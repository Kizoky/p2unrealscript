//=============================================================
//   Axe
//   Eternal Damnation
//   MaDJacKaL
//=============================================================
class AxeAttachment extends P2WeaponAttachment;

simulated event ThirdPersonEffects()
{
	// have pawn play firing anim
	if ( Instigator != None )
		Instigator.PlayFiring(1.5, FiringMode);
}

defaultproperties
{
     WeapClass=Class'AxeWeapon'
     FireSound=Sound'EDWeaponSounds.Weapons.Meatcleaver_slash'
     FiringMode="BATON1"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AW7Mesh.Weapons.TP_Axe'
}

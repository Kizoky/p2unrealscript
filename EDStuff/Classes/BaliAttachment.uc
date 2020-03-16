//=============================================================
//   Butterfly Knife 3rd Person
//   Eternal Damnation
//   Dopamine / MaDJacKaL
//=============================================================
class BaliAttachment extends P2WeaponAttachment;

simulated event ThirdPersonEffects()
{
	// have pawn play firing anim
	if ( Instigator != None )
		Instigator.PlayFiring(1.5, FiringMode);
}

defaultproperties
{
     WeapClass=Class'BaliWeapon'
     FireSound=Sound'EDWeaponSounds.Weapons.Meatcleaver_slash'
     FiringMode="BATON1"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ED_TPMeshes.Weapons.TP_Butterfly'
}

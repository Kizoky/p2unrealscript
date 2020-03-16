///////////////////////////////////////////////////////////////////////////////
// Baton attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class BatonAttachment extends P2WeaponAttachment;

simulated event ThirdPersonEffects()
{
	// have pawn play firing anim
	if ( Instigator != None )
	{
		if (BatonWeapon(Instigator.Weapon).bAltFiring)
			Instigator.PlayFiring(1.5, FiringMode);
		else
			Instigator.PlayFiring(1.0, FiringMode);
	}
}

defaultproperties
	{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.Baton3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	FiringMode="BATON1"
	WeapClass=class'BatonWeapon'
	}

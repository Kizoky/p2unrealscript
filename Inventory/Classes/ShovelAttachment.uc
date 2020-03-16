///////////////////////////////////////////////////////////////////////////////
// Shovel attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class ShovelAttachment extends P2WeaponAttachment;

simulated event ThirdPersonEffects()
{
	// have pawn play firing anim
	if ( Instigator != None )
	{
		if (ShovelWeapon(Instigator.Weapon).bAltFiring)
			Instigator.PlayFiring(2.0, FiringMode);
		else
			Instigator.PlayFiring(1.5, FiringMode);
	}
}

defaultproperties
	{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.Shovel3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=0)
	FiringMode="SHOVEL1"
	WeapClass=class'ShovelWeapon'
	}

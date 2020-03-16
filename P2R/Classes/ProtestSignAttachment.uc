class ProtestSignAttachment extends P2WeaponAttachment;

simulated event ThirdPersonEffects()
{
	// have pawn play firing anim
	if ( Instigator != None )
	{
		if (ProtestSignWeapon(Instigator.Weapon).bAltFiring)
			Instigator.PlayFiring(2.0, FiringMode);
		else
			Instigator.PlayFiring(1.5, FiringMode);
	}
}

defaultproperties
{
	WeapClass=Class'ProtestSignWeapon'
	FiringMode="SHOVEL1"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Timb_mesh.picket_timb.picket_timb'
	Skins(0)=Texture'Timb.picket.protest19'
}

///////////////////////////////////////////////////////////////////////////////
// Sledge attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class SledgeAttachment extends P2WeaponAttachment;

simulated event ThirdPersonEffects()
{
	// have pawn play firing anim
	if ( Instigator != None )
		Instigator.PlayFiring(2.0, FiringMode);
}

defaultproperties
{
     WeapClass=Class'AWInventory.SledgeWeapon'
     FiringMode="SHOVEL1"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AWWeaponStatic.Weapons.Sledge_2'
}

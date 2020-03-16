///////////////////////////////////////////////////////////////////////////////
// Machete attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class MacheteAttachment extends P2WeaponAttachment;

simulated event ThirdPersonEffects()
{
	// have pawn play firing anim
	if ( Instigator != None )
	{
		Instigator.PlayFiring(1.5, FiringMode);
	}
}

defaultproperties
{
     WeapClass=Class'AWInventory.MacheteWeapon'
     FiringMode="SHOVEL1"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AWWeaponStatic.Weapons.Machete_2'
}

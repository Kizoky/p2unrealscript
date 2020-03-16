///////////////////////////////////////////////////////////////////////////////
// Baton attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class FistsAttachment extends P2WeaponAttachment;

simulated event ThirdPersonEffects()
{
	// spawn 3rd person effects

	// have pawn play firing anim
	if ( Instigator != None )
		Instigator.PlayFiring(2.0,FiringMode);

	if (MuzzleFlash3rd!=None)
	{
		MuzzleFlash3rd.Flash();

		// Play MP sounds on everyone's computers
		if(FireSound != None
			&& MuzzleFlash3rd.GetStateName() == 'Visible'
			&& (Level.Game == None
				|| !FPSGameInfo(Level.Game).bIsSinglePlayer))
			Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, TransientSoundRadius, GetRandPitch());
	}
}

defaultproperties
{
	DrawType=DT_None
	FiringMode="FISTS"
	WeapClass=class'FistsWeapon'
}

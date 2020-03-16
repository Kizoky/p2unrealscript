//=============================================================
//   Hedge Clippers 3rd Person
//   Eternal Damnation
//   Dopamine|Silent-Scope|MaDJacKaL
//=============================================================
class ShearsAttachment extends P2WeaponAttachment;

var float firespeed,animspeed,animdelay;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	bStasis=false;
}

simulated event Timer()
{
	PlayAnim('clip',animspeed);
}

simulated event ThirdPersonEffects()
{
	// have pawn play firing anim
	SetTimer(animdelay, false);
	if ( Instigator != None )
		Instigator.PlayFiring(firespeed, FiringMode);

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
	WeapClass=Class'ShearsWeapon'
	FireSound=Sound'EDWeaponSounds.Fight.HedgeClippers_shoot1'
	FiringMode="CLIPPER1"
	bClientAnim=True
	Mesh=SkeletalMesh'ED_Weapons.Clippers3rdMesh'
	DrawType=DT_Mesh
	animspeed=1
	firespeed=4
	animdelay=0.1
}

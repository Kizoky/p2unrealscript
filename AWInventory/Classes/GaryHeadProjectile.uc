//////////////////////////////////////////////////////////////////////////////
// GaryHeadProjectile.
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// laughing gary heads--hurts things on contact
//
///////////////////////////////////////////////////////////////////////////////
class GaryHeadProjectile extends VomitProjectile;

// Added by Man Chrzan: xPatch 2.0
var sound StartSound;
var sound BurningSound;
var float BurningSoundVolume;

///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	local vector useloc;

	// Don't do anything if there's no damage
	if(Dam <= 0)
		return;

	// Bludgeoning can deflect heads
	if(ClassIsChildOf(damageType, class'BludgeonDamage'))
	{
		if(InstigatedBy != None)
			useloc = InstigatedBy.Location;
		else
			useloc = hitlocation;
		PerformBounce(Normal(useloc - Location));
	}
	else
		Super.TakeDamage(Dam, instigatedBy, hitlocation, momentum, damageType);
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	// Stop all sounds
	PlaySound(StartSound, SLOT_Misc, 0.01, false, 200.0, 1.0);

	Super.Destroyed();
}

auto state Flying
{
	simulated function Timer()
	{
		PlaySound(BurningSound, SLOT_Misc, BurningSoundVolume, false, 200.0, 1.0);
		SetTimer(GetSoundDuration(BurningSound), false);
	}

	function BeginState()
	{
		PlaySound(StartSound, SLOT_None, 1.0, false, 200.0, 1.0);
		PlaySound(BurningSound, SLOT_Misc, BurningSoundVolume, false, 200.0, 1.0);
		SetTimer(GetSoundDuration(BurningSound), false);
	}
}

defaultproperties
{
     TrailClass=Class'FX.GrenadeTrail'
     DrawType=DT_Mesh
     //AmbientSound=Sound'GaryDialog.gary_bwahahaha'
	 AmbientSound=None	 // Change by Man Chrzan: xPatch 2.0
     Mesh=SkeletalMesh'heads.Gary'
     DrawScale=1.000000
     SoundRadius=50.000000
     SoundVolume=255
     SoundPitch=64
     TransientSoundVolume=255.000000
     TransientSoundRadius=50.000000
	 
	 // Aded by Man Chrzan: xPatch 2.0
	 StartSound=Sound'GaryDialog.gary_bwahahaha'
     BurningSound=Sound'WeaponSounds.fire_large'
	 BurningSoundVolume=1.0
}

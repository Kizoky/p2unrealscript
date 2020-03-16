//////////////////////////////////////////////////////////////////////////////
// GaryHeadProjectile.
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// laughing gary heads--hurts things on contact
//
///////////////////////////////////////////////////////////////////////////////
class GaryHeadProjectile extends VomitProjectile;

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

defaultproperties
{
     TrailClass=Class'FX.GrenadeTrail'
     DrawType=DT_Mesh
     AmbientSound=Sound'GaryDialog.gary_bwahahaha'
     Mesh=SkeletalMesh'heads.Gary'
     DrawScale=1.000000
     SoundRadius=50.000000
     SoundVolume=255
     SoundPitch=64
     TransientSoundVolume=255.000000
     TransientSoundRadius=50.000000
}

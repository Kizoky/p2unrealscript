///////////////////////////////////////////////////////////////////////////////
// NapalmExplosion
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
// 
///////////////////////////////////////////////////////////////////////////////
class NapalmExplosion extends MolotovExplosion;

defaultproperties
{
	MyDamageType = class'NapalmDamage'

	puddclass = class'FireNapalmPuddle'
	pillclass = class'FirePillar'
	ballclass = class'FireBall'
	breakclass= None

	ExplosionMag=0
	ExplosionRadius=600
	ExplosionDamage=150
	ExplodingSound=Sound'WeaponSounds.Napalm_explode'
}

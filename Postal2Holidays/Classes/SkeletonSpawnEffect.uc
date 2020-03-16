///////////////////////////////////////////////////////////////////////////////
// MolotovExplosion
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
// 
// Effect and damage for molotov cocktails
///////////////////////////////////////////////////////////////////////////////
class SkeletonSpawnEffect extends MolotovExplosion;

defaultproperties
{
	DelayToHurtTime=0.2
	ExplosionMag=0
	ExplosionRadius=0
	ExplosionDamage=0
	MyDamageType=None
    ExplodingSound=Sound'LevelSoundsToo.library.flame_burst01'

	puddclass = class'FirePuddle'
	pillclass = class'FirePillar'
	ballclass = class'FireBall'
	breakclass= None

	LifeSpan=5.0
	TransientSoundRadius=600
}

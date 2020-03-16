///////////////////////////////////////////////////////////////////////////////
// PlagueExplosion
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
// 
// Effect and damage for chemical-tipped rockets
///////////////////////////////////////////////////////////////////////////////
class PlagueExplosion extends MolotovExplosion;

// Special vars for the gas effects.
var float GasRadius;
var float GasDamage;
var class<P2Damage> GasDamageType;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function MakeBase()
	{
		local vector loc;

		loc = 2*UseNormal + Location;
		spawn(class'ChemBase',,,loc);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Central fire pillar
	///////////////////////////////////////////////////////////////////////////////
	function MakePillar()
	{
		local vector loc;

		loc = 2*UseNormal + Location;
		spawn(class'ChemPillar',,,loc);
	}
Begin:
	MakeBase();	
	MakePillar();
	PlaySound(ExplodingSound,,1.0,,,,true);
	CheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, ForceLocation);
	Sleep(DelayToHurtTime);
	CheckHurtRadius(GasDamage, GasRadius, GasDamageType, 0, ForceLocation);
	NotifyPawns();
	Sleep(0.6);
}

defaultproperties
{
	DelayToHurtTime=0.2

	ExplosionMag=130000
	ExplosionRadius=550
	GasRadius=700
	GasDamage=200
	ExplosionDamage=200
	GasDamageType=class'ChemDamage'
	MyDamageType = class'ExplodedDamage'
    ExplodingSound=Sound'WeaponSounds.explosion_long'

	pillclass = class'ChemPillar'
	ballclass = class'ChemBall'

	LifeSpan=5.0
}

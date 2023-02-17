/**
 * MutantChampFireballExplosion
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Configurable (or at least during development) for Mutant Champ's fireballs.
 * We need this as the default grenade explosion damage and radius may be a bit
 * high for this boss fight
 *
 * @author Gordon Cheng
 */
class MutantChampFireballExplosion extends GrenadeExplosion;

auto state Exploding
{
Begin:
	if (bGroundHit)
 		PlaySound(GrenadeExplodeGround,,1.0,,,,true);
	else
		PlaySound(GrenadeExplodeAir,,1.0,,,,true);

	Sleep(DelayToHurtTime);

	CheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, Location);
	NotifyPawns();
}

defaultproperties
{
    ExplosionDamage=30
    ExplosionRadius=450

    MyDamageType=class'MutantChampFireballDamage'
}

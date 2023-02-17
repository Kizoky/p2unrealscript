/**
 * PLWeaponBulletHitPack
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Like the normal HitPacks, this Actor is responsibly for creating and using
 * them, however, unlike them, a single weapon only uses this one HitPack
 * Actor for the weapon's entire existance, same with the Emitters used for
 * various effects
 *
 * @author Gordon Cheng
 */
class PLWeaponBulletHitPack extends Actor;

/** Number of particles to spawn for each respective particle Emitter */
var range SmokeParticleCount;
var range SparkParticleCount;
var range DirtParticleCount;

/** Various Emitter classes to spawn */
var class<Splat> DecalClass;
var class<PLPersistantEmitter> SmokeEmitterClass;
var class<PLPersistantEmitter> SparkEmitterClass;
var class<PLPersistantEmitter> DirtEmitterClass;

/** Impact sounds, although the minigun really shouldn't use these */
var sound WallHit[2];
var sound RicHit[2];

/** Chances of having some of the effects spawn */
var float SparkChance;
var float DirtChance;
var float WallHitSoundChance;
var float RicochetSoundChance;

/** Various Emitters we'll tell to spawn their corresponding particle effects */
var PLPersistantEmitter SmokeEmitter;
var PLPersistantEmitter SparkEmitter;
var PLPersistantEmitter DirtEmitter;

/** Overriden so we can create all our effect Emitters */
simulated function PostBeginPlay() {

    super.PostBeginPlay();

    if (SmokeEmitterClass != none)
        SmokeEmitter = Spawn(SmokeEmitterClass);

    if (SparkEmitterClass != none)
        SparkEmitter = Spawn(SparkEmitterClass);

    if (DirtEmitterClass != none)
        DirtEmitter = Spawn(DirtEmitterClass);
}

/** Copied from BulletHitPack */
simulated function float GetRandPitch() {

    return 0.96 + FRand() * 0.08;
}

/**
 * Tell our particle Emitters to spawn their corresponding effects at the
 * specified location and rotation
 *
 * @param EffectLocation - Location in the world where the effects spawn
 * @param EffectRotation - Rotation, usually the normal vector, for the effects
 */
function SpawnImpactEffects(vector EffectLocation, rotator EffectRotation) {

    local rotator NewRot;

    // Spawn our impact smoke particles
    if (SmokeEmitter != none) {

        SmokeEmitter.SetLocation(EffectLocation);
        SmokeEmitter.SetRotation(EffectRotation);

        SmokeEmitter.SpawnParticle(0, int(RandRange(SmokeParticleCount.Min,
            SmokeParticleCount.Max)));

        if (FRand() < WallHitSoundChance)
		    SmokeEmitter.PlaySound(WallHit[Rand(ArrayCount(WallHit))],,,,,
                GetRandPitch());
    }
    else
        log("ERROR: SmokeEmitter not found");

    // Spawn our bullet hole projector
    if (DecalClass != none) {

        NewRot = rotator(-vector(EffectRotation));
		NewRot.Roll = int(65536.0 * FRand());

        Spawn(DecalClass, Owner,, EffectLocation, NewRot);
	}

	// Spawn our dirt particles
    if (DirtEmitter != none && FRand() < DirtChance) {

	    DirtEmitter.SetLocation(EffectLocation);
	    DirtEmitter.SetRotation(EffectRotation);

	    DirtEmitter.SpawnParticle(0, int(RandRange(DirtParticleCount.Min,
            DirtParticleCount.Max)));
	}
	else
        log("ERROR: DirtEmitter not found");

	// Spawn the bullet sparks when it hits stuff
    if (SparkEmitter != none && FRand() < SparkChance) {

	    SparkEmitter.SetLocation(EffectLocation);
	    SparkEmitter.SetRotation(EffectRotation);

	    SparkEmitter.SpawnParticle(0, int(RandRange(SparkParticleCount.Min,
            SparkParticleCount.Max)));

        if (FRand() < RicochetSoundChance)
			SparkEmitter.PlaySound(RicHit[Rand(ArrayCount(RicHit))],,,,,
                GetRandPitch());
	}
	else
        log("ERROR: SparkEmitter not found");
}

defaultproperties
{
    bHidden=true

    SmokeParticleCount=(Min=2,Max=2)
    SparkParticleCount=(Min=3,Max=3)
    DirtParticleCount=(Min=2,Max=2)

    WallHit(0)=sound'WeaponSounds.bullet_hitwall1'
    WallHit(1)=sound'WeaponSounds.bullet_hitwall2'

    RicHit(0)=sound'WeaponSounds.bullet_ricochet1'
    RicHit(1)=sound'WeaponSounds.bullet_ricochet2'

    DirtChance=0.3
    SparkChance=0.3

    RicochetSoundChance=1
    WallHitSoundChance=1
}
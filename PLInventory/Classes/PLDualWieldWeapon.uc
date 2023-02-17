/**
 * PLDualWieldWeapon
 * Copyright 2014, Running With Scissors, Inc.
 *
 * A simple extension of the P2DualWieldWeapon, only we add some support for
 * muzzle flash emitters based on the UT3 structure
 *
 * @author Gordon Cheng
 */
class PLDualWieldWeapon extends P2DualWieldWeapon;

/** MuzzleFlash Emitters */
var name MuzzleFlashBone;
var class<PLPersistantEmitter> MuzzleFlashEmitterClass;

var PLPersistantEmitter MuzzleFlashEmitter;

simulated function PostBeginPlay() {
    super.PostBeginPlay();

    if (MuzzleFlashEmitter == none && MuzzleFlashEmitterClass != none) {
        MuzzleFlashEmitter = Spawn(MuzzleFlashEmitterClass);

        if (MuzzleFlashEmitter != none && MuzzleFlashBone != '' &&
            MuzzleFlashBone != 'None')
            AttachToBone(MuzzleFlashEmitter, MuzzleFlashBone);
    }
}

/** Overriden so we can play miscellaneous firing effects */
simulated function LocalFire() {
    super.LocalFire();

    PlayFireEffects();
}

simulated function LocalAltFire() {
    super.LocalAltFire();

    PlayAltFireEffects();
}

/** Plays various fire effects */
function PlayFireEffects() {
    if (MuzzleFlashEmitter != none) {
        MuzzleFlashEmitter.SetDirection(vector(Rotation), 0.0);
        MuzzleFlashEmitter.SpawnParticle(0, 1);
    }
}

/**
 * Plays various alt firing effects. By default, we play the primary firing
 * effects
 */
function PlayAltFireEffects() {
    PlayFireEffects();
}

/** Overriden to add support for Emitter destruction */
event Destroyed() {
    super.Destroyed();

    if (MuzzleFlashEmitter != none)
        MuzzleFlashEmitter.Destroy();
}

defaultproperties
{
}
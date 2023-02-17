/**
 * PLPersistantEmitter
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A special persistant emitter we can use to spawn particles whenever we
 * need them as opposed to spawning a new Emitter object over and over again
 * every time we fire
 *
 * @author Gordon Cheng
 */
class PLPersistantEmitter extends P2Emitter;

/** Overriden so we can point the muzzle flash in certain directions */
simulated function SetDirection(vector Dir, float Dist) {

    local vector ParticleDir;

    ParticleDir.X = float(rotator(Dir).Yaw) / 65536.0;
    ParticleDir.Y = float(rotator(Dir).Pitch) / 65536.0;

    Emitters[0].StartSpinRange.X.Min = ParticleDir.X;
    Emitters[0].StartSpinRange.X.Max = ParticleDir.X;

    Emitters[0].StartSpinRange.Y.Min = ParticleDir.Y;
    Emitters[0].StartSpinRange.Y.Max = ParticleDir.Y;
}

/**
 * Causes one of our ParticleEmitters to spawn a specified number of particles
 *
 * @param Index - Index of the ParticleEmitter to spawn particles from
 * @param Amount - Number of particles to spawn from the Emitter
 */
function SpawnParticle(int Index, int Amount) {

    if (Index > 0 && Index < Emitters.length && Amount > 0)
        return;

    Emitters[Index].SpawnParticle(Amount);
}

defaultproperties
{
    AutoDestroy=false
    AutoReset=false
}
/**
 * MountedWeaponTracer
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Tracer for the Minigun. We're gonna be spawning a lot of particles, so it's
 * better to spawn lots of particles, rather than lots of Emitters.
 *
 * @author Gordon Cheng
 */
class MountedWeaponTracer extends PLPersistantEmitter;

/** General tracer configuration values */
var int TracerFrequency;
var float TracerSpeed;
var float NPCTracerSpeed;

var float TracerStaticMeshLength;

/** Misc objects and values */
var bool bNPCMountedWeaponUser;
var int SpawnCount;

/** Overriden so we can set the spawn offset based off the StaticMesh scaling */
simulated function PostBeginPlay() {
    super.PostBeginPlay();
}

/** Overriden so we can set the lifespan of the particle and velocity */
simulated function SetDirection(vector Dir, float Dist) {

    local vector ParticleVelocity;

    super.SetDirection(Dir, Dist);

    if (bNPCMountedWeaponUser) {
        Emitters[0].LifetimeRange.Min = Dist / NPCTracerSpeed;
        Emitters[0].LifetimeRange.Max = Dist / NPCTracerSpeed;

        ParticleVelocity = Dir * NPCTracerSpeed;
    }
    else {
        Emitters[0].LifetimeRange.Min = Dist / TracerSpeed;
        Emitters[0].LifetimeRange.Max = Dist / TracerSpeed;

        ParticleVelocity = Dir * TracerSpeed;
    }

    Emitters[0].StartVelocityRange.X.Min = ParticleVelocity.X;
    Emitters[0].StartVelocityRange.X.Max = ParticleVelocity.X;

    Emitters[0].StartVelocityRange.Y.Min = ParticleVelocity.Y;
    Emitters[0].StartVelocityRange.Y.Max = ParticleVelocity.Y;

    Emitters[0].StartVelocityRange.Z.Min = ParticleVelocity.Z;
    Emitters[0].StartVelocityRange.Z.Max = ParticleVelocity.Z;
}

/** Overriden so we spawn a particle only after every number of rounds */
function SpawnParticle(int Index, int Amount) {
    SpawnCount++;

    if (SpawnCount == TracerFrequency || TracerFrequency < 2) {
        SpawnCount = 0;
        super.SpawnParticle(Index, Amount);
    }
}

defaultproperties
{
    Begin Object class=MeshEmitter name=MeshEmitter0
        CoordinateSystem=PTCS_Independent
        StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Tracer'
        MaxParticles=1000
        RespawnDeadParticles=false
        SpinParticles=true
        StartSizeRange=(X=(Min=15,Max=15),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        InitialParticlesPerSecond=0
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_Regular
        SecondsBeforeInactive=0
        Name="MeshEmitter0"
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter0'

    TracerFrequency=1
    TracerSpeed=65536
    NPCTracerSpeed=16384

    AmbientGlow=254
    TracerStaticMeshLength=64
}

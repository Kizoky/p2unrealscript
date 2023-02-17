/**
 * ObeseBitchRockDropExplosion
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Explosions that will appear on the ground as Obese Bitch's loosened
 * stalactites that fall from the ceiling
 *
 * @author Gordon Cheng
 */
class ObeseBitchRockDropExplosion extends P2Explosion;

defaultproperties
{
    MyDamageType=class'ObeseBitchMeleeDamage'

    ExplodingSound=sound'LevelSoundsToo.library.woodCrash01'

    ExplosionMag=60000
    ExplosionDamage=60
    ExplosionRadius=250

    Begin Object class=MeshEmitter name=MeshEmitter0
		SecondsBeforeInactive=0
        StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock02'
        Acceleration=(Z=-800)
        MaxParticles=16
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-50,Max=50),Y=(Min=-50,Max=50),Z=(Min=30,Max=200))
        UseCollision=true
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        StartSpinRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=1.40000,Max=2.6),Y=(Min=0.8,Max=1.8),Z=(Min=1.4,Max=4))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        LifetimeRange=(Min=3,Max=4)
        StartVelocityRange=(X=(Min=-400,Max=400),Y=(Min=-400,Max=400),Z=(Max=300))
        Name="MeshEmitter0"
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter0'

     Begin Object class=MeshEmitter name=MeshEmitter1
		SecondsBeforeInactive=0
        StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock03'
        Acceleration=(Z=-800)
        MaxParticles=16
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-50,Max=50),Y=(Min=-50,Max=50),Z=(Min=30,Max=200))
        UseCollision=true
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        StartSpinRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=1.4,Max=2.6),Y=(Min=0.8,Max=1.8),Z=(Min=1.4,Max=4))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        LifetimeRange=(Min=3,Max=4)
        StartVelocityRange=(X=(Min=-400,Max=400),Y=(Min=-400,Max=400),Z=(Max=300))
        Name="MeshEmitter1"
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter1'

    AutoDestroy=true
    LifeSpan=5
    TransientSoundRadius=200
}

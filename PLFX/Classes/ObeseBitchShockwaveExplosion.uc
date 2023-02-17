/**
 * ObeseBitchShockwaveExplosion
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Explosions that will appear on the ground as Obese Bitch's shockwave
 * travels along the ground
 *
 * @author Gordon Cheng
 */
class ObeseBitchShockwaveExplosion extends P2Explosion;

defaultproperties
{
    MyDamageType=class'ObeseBitchMeleeDamage'

    ExplodingSound=sound'WeaponSounds.Grenade_ExplodeAir'

    ExplosionMag=60000
    ExplosionDamage=60
    ExplosionRadius=250

    Begin Object class=SpriteEmitter name=SpriteEmitter0
		SecondsBeforeInactive=0
        MaxParticles=7
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-30,Max=30),Y=(Min=-30,Max=30),Z=(Min=-30,Max=30))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=0.1))
        StartSpinRange=(X=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeTime=0,RelativeSize=0)
        SizeScale(1)=(RelativeTime=0.1,RelativeSize=0.7)
        SizeScale(2)=(RelativeTime=1,RelativeSize=1)
        StartSizeRange=(X=(Min=170,Max=220))
        InitialParticlesPerSecond=100
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        LifetimeRange=(Min=2.,Max=2.5)
        StartVelocityRange=(X=(Min=-300,Max=300),Y=(Min=-300,Max=300),Z=(Min=-100,Max=100))
        VelocityLossRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object class=SpriteEmitter name=SpriteEmitter1
		SecondsBeforeInactive=0
        Acceleration=(Z=-600)
        MaxParticles=20
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-30,Max=30),Y=(Min=-30,Max=30),Z=(Min=-30,Max=30))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=2))
        StartSpinRange=(X=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=5,Max=15))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=true
        LifetimeRange=(Min=1,Max=1.5)
        StartVelocityRange=(X=(Min=-600,Max=600),Y=(Min=-600,Max=600),Z=(Max=500))
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'

    Begin Object class=SpriteEmitter name=SpriteEmitter2
		SecondsBeforeInactive=0
        Acceleration=(Z=-1)
        UseDirectionAs=PTDU_Up
        UseColorScale=true
        ColorScale(0)=(color=(B=100,G=120,R=160))
        ColorScale(1)=(RelativeTime=0.2,color=(B=100,G=100,R=128))
        ColorScale(2)=(RelativeTime=1,color=(B=100,G=100,R=128))
        FadeOut=true
        MaxParticles=12
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-20,Max=20),Y=(Min=-20,Max=20),Z=(Min=-50,Max=-20))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeTime=0,RelativeSize=0)
        SizeScale(1)=(RelativeTime=0.3,RelativeSize=0.7)
        SizeScale(2)=(RelativeTime=1,RelativeSize=1)
        StartSizeRange=(X=(Max=200),Y=(Min=200,Max=400))
        InitialParticlesPerSecond=3000
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'nathans.Skins.pour2'
        LifetimeRange=(Min=2.2,Max=2.7)
        StartVelocityRange=(X=(Min=-400,Max=400),Y=(Min=-400,Max=400),Z=(Min=220,Max=320))
        VelocityLossRange=(X=(Min=1.5,Max=1.5),Y=(Min=1.5,Max=1.5),Z=(Min=1.5,Max=1.5))
        Name="SpriteEmitter2"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter2'

    Begin Object class=MeshEmitter name=MeshEmitter0
		SecondsBeforeInactive=0
        StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock02'
        Acceleration=(Z=-800)
        MaxParticles=16
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-10,Max=10),Y=(Min=-10,Max=10),Z=(Min=-30,Max=30))
        UseCollision=true
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        StartSpinRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=0.70000,Max=1.3),Y=(Min=0.40000,Max=0.9),Z=(Min=0.7,Max=2))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        LifetimeRange=(Min=3,Max=4)
        StartVelocityRange=(X=(Min=-400,Max=400),Y=(Min=-400,Max=400),Z=(Max=300))
        Name="MeshEmitter0"
    End Object
    Emitters(3)=MeshEmitter'MeshEmitter0'

     Begin Object class=MeshEmitter name=MeshEmitter1
		SecondsBeforeInactive=0
        StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock03'
        Acceleration=(Z=-800)
        MaxParticles=16
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-10,Max=10),Y=(Min=-10,Max=10),Z=(Min=-30,Max=30))
        UseCollision=true
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        StartSpinRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=0.70000,Max=1.3),Y=(Min=0.40000,Max=0.9),Z=(Min=0.7,Max=2))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        LifetimeRange=(Min=3,Max=4)
        StartVelocityRange=(X=(Min=-400,Max=400),Y=(Min=-400,Max=400),Z=(Max=300))
        Name="MeshEmitter1"
    End Object
    Emitters(4)=MeshEmitter'MeshEmitter1'

    AutoDestroy=true
    LifeSpan=5
    TransientSoundRadius=200
}

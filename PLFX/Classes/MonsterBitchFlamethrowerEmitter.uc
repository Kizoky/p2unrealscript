/**
 * MonsterBitchFlamethrowerEmitter
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Apparently you ex-wife also has a serious case of face melting halitosis.
 *
 * @author Gordon Cheng
 */
class MonsterBitchFlamethrowerEmitter extends FlamethrowerEmitter;

defaultproperties
{
    Begin Object class=SpriteEmitter name=SpriteEmitterMBFlame
        Acceleration=(Z=100)
        UseColorScale=true
        ColorScale(0)=(color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.5,color=(G=255,R=255))
        ColorScale(2)=(RelativeTime=0.7,color=(G=128,R=255))
        FadeOutStartTime=0.8
        FadeOut=true
        MaxParticles=200
        RespawnDeadParticles=false
        UseRotationFrom=PTRS_Actor
        SpinParticles=true
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1,RelativeSize=2.5)
        StartSizeRange=(X=(Min=25,Max=60),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        ParticlesPerSecond=50
        InitialParticlesPerSecond=50
        AutomaticInitialSpawning=false
        Texture=Texture'nathans.Skins.firegroup2'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.5,Max=2)
        StartVelocityRange=(X=(Min=900,Max=1250),Y=(Min=-75,Max=75),Z=(Min=-75,Max=75))
        Name="SpriteEmitterMBFlame"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitterMBFlame'

    Range=3000
    Angle=10
    DamageRate=25

    FireRingInterval=0.5
    FireRingMinDistance=100
    FireRingFlatGround=0.8
}

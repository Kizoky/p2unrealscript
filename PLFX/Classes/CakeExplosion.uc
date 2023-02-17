/**
 * CakeExplosion
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Chunks of delicous cake and frosting
 *
 * @author Gordon Cheng
 */
class CakeExplosion extends P2Emitter;

defaultproperties
{
    Begin Object class=SpriteEmitter name=SpriteEmitter0
        Acceleration=(Z=-600)
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.8,color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.9,color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=1,color=(B=192,G=192,R=192))
        ColorScaleRepeats=1
        FadeOut=true
        FadeIn=true
        MaxParticles=40
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-3,Max=3))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=2))
        StartSpinRange=(X=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=5,Max=35))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'MrD_PL_Tex.Misc.cakechunkstex'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        UseRandomSubdivision=true
        LifetimeRange=(Min=2,Max=2.5)
        StartVelocityRange=(X=(Min=300,Max=-300),Y=(Min=300,Max=-300),Z=(Max=500))
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object class=MeshEmitter name=MeshEmitter0
        StaticMesh=StaticMesh'MrD_PL_Mesh.junkyard.CakeChunk'
        Acceleration=(Z=-1000)
        UseCollision=true
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        MaxParticles=40
        RespawnDeadParticles=false
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        StartSpinRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        UseSizeScale=true
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=0.3,Max=1.5),Y=(Min=0.3,Max=1.5),Z=(Min=0.8,Max=1.5))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        SecondsBeforeInactive=0
        LifetimeRange=(Min=2.5)
        StartVelocityRange=(X=(Min=300,Max=-300),Y=(Min=300,Max=-300),Z=(Max=300))
        Name="MeshEmitter0"
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter0'

    Begin Object class=MeshEmitter name=MeshEmitter1
        StaticMesh=StaticMesh'MrD_PL_Mesh.junkyard.cakechunk02'
        Acceleration=(Z=-975)
        UseCollision=true
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        RespawnDeadParticles=false
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        StartSpinRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        SecondsBeforeInactive=0
        LifetimeRange=(Min=2.5)
        StartVelocityRange=(X=(Min=300,Max=-300),Y=(Min=300,Max=-300),Z=(Max=300))
        Name="MeshEmitter1"
    End Object
    Emitters(2)=MeshEmitter'MeshEmitter1'

    Begin Object class=SpriteEmitter name=SpriteEmitter1
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.5,color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.9,color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.3,color=(B=255,G=255,R=255))
        MaxParticles=15
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-15,Max=15),Y=(Min=-15,Max=15),Z=(Min=-15,Max=15))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=0.1))
        StartSizeRange=(X=(Min=120,Max=250),Y=(Min=250,Max=250),Z=(Min=250,Max=250))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        LifetimeRange=(Min=0.5,Max=0.8)
        Name="SpriteEmitter1"
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter1'
}
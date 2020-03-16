/**
 * SkeletonExplosion
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Yes, skeletons can explode into gibs too, only there's no meat on dem bones
 *
 * @author Gordon Cheng
 */
class SkeletonExplosion extends CatExplosion;

var sound SkeletonGibSound;

simulated function PostBeginPlay() {
    super.PostBeginPlay();

    if (SkeletonGibSound != none)
        PlaySound(SkeletonGibSound);
}

simulated function PostNetBeginPlay() {
	local int i;

	super.PostNetBeginPlay();

	if (Level.NetMode == NM_DedicatedServer)
		for(i=0;i<Emitters.Length;i++)
			Emitters[i].Disabled = true;
}

defaultproperties
{
    Begin Object class=MeshEmitter name=MeshEmitter0
		SecondsBeforeInactive=0
        StaticMesh=StaticMesh'Timb_mesh.Champ.champ_bone_timb'
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
    Emitters(0)=MeshEmitter'MeshEmitter0'

    Begin Object class=SpriteEmitter name=SpriteEmitter0
		SecondsBeforeInactive=0
        UseColorScale=true
        ColorScale(0)=(color=(R=255))
        ColorScale(1)=(RelativeTime=1,color=(R=255))
        MaxParticles=8
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-10,Max=10),Y=(Min=-10,Max=10),Z=(Min=-30,Max=30))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=0.1))
        StartSpinRange=(X=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=0.1)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1)
        StartSizeRange=(X=(Min=100,Max=150))
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        LifetimeRange=(Min=4,Max=5)
        Name="SpriteEmitter0"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter0'

    SkeletonGibSound=sound'LevelSoundsToo.library.woodCrash02'

    AutoDestroy=true
	Lifespan=6
}
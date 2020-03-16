class PawnExplosion extends CatExplosion;


simulated function PostNetBeginPlay()
{
	local int i;

	Super.PostNetBeginPlay();

	// We don't want this to run on the server, but we can't
	// destroy it here because the client version will then never
	// get made, so we just turn it off,and the lifespan will clean
	// it up
	if(Level.NetMode == NM_DedicatedServer)
	{
		for(i=0; i<Emitters.Length; i++)
		{
			Emitters[i].Disabled=true;
		}
	}
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-600.000000)
        MaxParticles=10
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=25.000000,Max=45.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=500.000000))
        Name="SpriteEmitter3"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter3'
    Begin Object Class=MeshEmitter Name=MeshEmitter0
		SecondsBeforeInactive=0.0
        StaticMesh=StaticMesh'Timb_mesh.fooo.nasty_deli2_timb'
        Acceleration=(Z=-800.000000)
        MaxParticles=8
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-30.000000,Max=30.000000))
        UseCollision=True
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=0.70000,Max=1.300000),Y=(Min=0.40000,Max=0.900000),Z=(Min=0.700000,Max=2.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=3.00000,Max=4.000000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Max=300.000000))
        Name="MeshEmitter0"
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter0'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        MaxParticles=6
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=100.000000,Max=150.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=4.000000,Max=5.000000)
        Name="SpriteEmitter5"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter5'
    AutoDestroy=true
	Lifespan=6
}
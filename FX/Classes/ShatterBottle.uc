///////////////////////////////////////////////////////////////////////////////
// ShatterBottle.
//
// The first emitter is the falling glass, the second emitter is the glass
// lying on the ground.
///////////////////////////////////////////////////////////////////////////////
class ShatterBottle extends P2Emitter;

#exec TEXTURE IMPORT File=Textures\WaterSplash2.dds

defaultproperties
{
	/*
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter22
        Acceleration=(Z=-3000.000000)
        UseCollision=True
        DampingFactorRange=(X=(Min=0.500000,Max=0.900000),Y=(Min=0.500000,Max=0.900000),Z=(Min=0.400000,Max=0.700000))
        UseMaxCollisions=True
        MaxCollisions=(Min=3.000000,Max=3.000000)
        SpawnFromOtherEmitter=1
        SpawnAmount=1
        MaxParticles=15
        RespawnDeadParticles=False
        StartLocationRange=(Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000))
        StartSpinRange=(X=(Max=1.000000))
        DampRotation=True
        RotationDampingFactorRange=(X=(Min=0.500000,Max=0.800000))
        StartSizeRange=(X=(Min=6.000000,Max=10.000000),Y=(Min=6.000000,Max=10.000000))
        InitialParticlesPerSecond=5000.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.glassshards'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=6.000000,Max=6.000000)
        StartVelocityRange=(X=(Min=25.000000,Max=250.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-100.000000,Max=200.000000))
        Name="SuperSpriteEmitter22"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter22'
	*/
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter8
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-3000.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        UseCollision=true
        UseMaxCollisions=true
        MaxCollisions=(Min=3.000000,Max=3.000000)
        SpawnFromOtherEmitter=1
        SpawnAmount=1
        DampingFactorRange=(X=(Min=0.500000,Max=0.900000),Y=(Min=0.500000,Max=0.900000),Z=(Min=0.400000,Max=0.700000))
        MaxParticles=15
        RespawnDeadParticles=false
        StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-10.000000,Max=10.000000))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=1.000000))
        StartSpinRange=(X=(Max=1.000000))
        DampRotation=true
        RotationDampingFactorRange=(X=(Min=0.500000,Max=0.800000))
        UseRegularSizeScale=true
        StartSizeRange=(X=(Min=2.000000,Max=5.000000),Y=(Min=2.000000,Max=5.000000))
        InitialParticlesPerSecond=5000.000000
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'nathans.Skins.glassshards'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        UseRandomSubdivision=true
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=-10.000000,Max=30.000000))
        Name="SuperSpriteEmitter8"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter8'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter23
        UseDirectionAs=PTDU_Normal
        MaxParticles=15
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        RespawnDeadParticles=False
        SpinParticles=True
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=5.000000),Y=(Min=2.000000,Max=5.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.glassshards'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=30.000000,Max=30.000000)
        Name="SuperSpriteEmitter23"
    End Object
    Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter23'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter83
        Acceleration=(Z=-930.000000)
        ColorScale(0)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=139,G=139,R=139))
        FadeOutStartTime=0.100000
        FadeOut=True
        MaxParticles=1
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.100000,RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
        InitialParticlesPerSecond=20.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'FX.WaterSplash2'
        LifetimeRange=(Min=0.500000,Max=0.300000)
        StartVelocityRange=(X=(Max=75.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=200.000000,Max=350.000000))
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=1.000000
        Name="SpriteEmitter83"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter83'
	Lifespan=40
}

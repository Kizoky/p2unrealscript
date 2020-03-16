class KevlarSicChunks extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter12
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        DampingFactorRange=(Z=(Min=0.500000))
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
		MaxParticles=2
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=0.500000,Max=0.800000),Y=(Min=14.000000,Max=18.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=0.700000,Max=1.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-300.000000,Max=300.000000))
        VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
        Name="SpriteEmitter12"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter12'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-600.000000)
        MaxParticles=4
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=5.000000,Max=12.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'MP_Misc.Kevlar.Kevlar_Sic_chunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=150.000000,Max=300.000000))
        Name="SpriteEmitter10"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter10'
     AutoDestroy=true
	 bNetOptional=true
}

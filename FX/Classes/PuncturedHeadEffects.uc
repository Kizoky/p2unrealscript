//=============================================================================
// PuncturedHeadEffects.
//=============================================================================
class PuncturedHeadEffects extends BodyEffects;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter10
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-300.000000)
        MaxParticles=3
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=4.000000,Max=7.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.600000,Max=0.800000)
        StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=100.000000,Max=500.000000))
        Name="SpriteEmitter10"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter10'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(A=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255))
        RespawnDeadParticles=False
        MaxParticles=3
        StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=40.000000,Max=90.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        Name="SpriteEmitter5"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter5'
	LifeSpan=5
    AutoDestroy=true
}

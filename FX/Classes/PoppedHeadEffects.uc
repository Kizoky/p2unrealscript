//=============================================================================
// PoppedHeadEffects.
//=============================================================================
class PoppedHeadEffects extends BodyEffects;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter24
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        RespawnDeadParticles=False
        MaxParticles=3
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=80.000000,Max=140.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.500000,Max=2.000000)
        Name="SpriteEmitter24"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter24'
	LifeSpan=5
    AutoDestroy=true
	ImpactRatio=0.001
}

//=============================================================================
// The end point for the trail. No visuals involved, only collision and physics
//=============================================================================
class AnthTrailMidPoint extends AnthTrailPoint;

function PostBeginPlay()
{
	// Don't call super
	VelocityMax = Emitters[0].MaxAbsVelocity;
}

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter19
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=64))
        FadeOutStartTime=4.000000
        FadeOut=True
        MaxParticles=40
        StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-60.000000,Max=60.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.080000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=200.000000,Max=300.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=5.000000,Max=6.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-20.000000,Max=20.000000))
		MaxAbsVelocity=(X=50,Y=50,Z=50);
        Name="SuperSpriteEmitter19"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter19'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter13
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=31,G=58,R=78))
        MaxParticles=25
        StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-60.000000,Max=60.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=10.000000
        ParticlesPerSecond=6.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Max=5.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-3.000000,Max=3.000000))
		MaxAbsVelocity=(X=50,Y=50,Z=50);
        Name="SuperSpriteEmitter13"
    End Object
    Emitters(1)=SuperSpriteEmitter'Fx.SuperSpriteEmitter13'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter14
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=38,G=72,R=89))
        MaxParticles=9
        StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-60.000000,Max=60.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        SizeScaleRepeats=2.000000
        StartSizeRange=(X=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=10.000000
        ParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Max=5.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-3.000000,Max=3.000000))
		MaxAbsVelocity=(X=50,Y=50,Z=50);
        Name="SuperSpriteEmitter14"
    End Object
    Emitters(2)=SuperSpriteEmitter'Fx.SuperSpriteEmitter14'
}
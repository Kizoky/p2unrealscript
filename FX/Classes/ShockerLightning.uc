//=============================================================================
// ShockerLightning
//=============================================================================
class ShockerLightning extends P2Emitter;


defaultproperties
{
    Begin Object Class=BeamEmitter Name=BeamEmitter1
		SecondsBeforeInactive=0.0
        // Changed by Man Chrzan: xPatch 2.0
		//BeamDistanceRange=(Min=10.000000,Max=12.000000)
		BeamDistanceRange=(Min=50.000000,Max=60.000000)  
        DetermineEndPointBy=PTEP_Distance
        LowFrequencyNoiseRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000),Z=(Min=-0.1000000,Max=0.100000))
        LowFrequencyPoints=5
        HighFrequencyNoiseRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000),Z=(Min=-0.100000,Max=0.100000))
		WarmupTicksPerSecond=5.0
		RelativeWarmupTime=1.0
        UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255))
        ColorScale(1)=(RelativeTime=0.300000)
        ColorScale(2)=(RelativeTime=0.600000,Color=(B=128,G=255))
        ColorScale(3)=(RelativeTime=1.000000)
        MaxParticles=6
        CoordinateSystem=PTCS_Relative
        UseSizeScale=True
        UseRegularSizeScale=False
        // Changed by Man Chrzan: xPatch 2.0
		//SizeScale(0)=(RelativeSize=0.500000)
        //SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		SizeScale(0)=(RelativeSize=2.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
        StartSizeRange=(X=(Min=0.800000,Max=1.400000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.lightning6'
        LifetimeRange=(Min=0.500000,Max=0.800000)
        StartVelocityRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=-0.30000,Max=0.300000),Z=(Min=-0.300000,Max=0.300000))
        Name="BeamEmitter1"
    End Object
    Emitters(0)=BeamEmitter'BeamEmitter1'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter42
		SecondsBeforeInactive=0.0
		WarmupTicksPerSecond=5.0
		RelativeWarmupTime=1.0
        UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255,R=128))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=255))
        MaxParticles=6
        CoordinateSystem=PTCS_Relative
        StartLocationRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000),Z=(Min=-0.100000,Max=0.100000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=1.000000,Max=3.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        // Changed by Man Chrzan: xPatch 2.0
		//SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000) 
        StartSizeRange=(X=(Min=1.000000,Max=1.600000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.blast1'
        LifetimeRange=(Min=0.400000,Max=0.700000)
        Name="SpriteEmitter42"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter42'
    AutoDestroy=true
}

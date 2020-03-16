//=============================================================================
// ShockerPawnLightning
//=============================================================================
class ShockerPawnLightning extends P2Emitter;


defaultproperties
{
    Begin Object Class=BeamEmitter Name=BeamEmitter1
		SecondsBeforeInactive=0.0
        BeamDistanceRange=(Min=60.000000,Max=90.000000)
        DetermineEndPointBy=PTEP_Distance
        LowFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        LowFrequencyPoints=5
        HighFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=1.000000,Max=2.000000))
        UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255))
        ColorScale(1)=(RelativeTime=0.300000)
        ColorScale(2)=(RelativeTime=0.600000,Color=(B=128,G=255))
        ColorScale(3)=(RelativeTime=1.000000)
        MaxParticles=8
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=6.000000,Max=8.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.lightning6'
        LifetimeRange=(Min=0.400000,Max=0.600000)
        StartVelocityRange=(X=(Min=-0.800000,Max=0.800000),Y=(Min=-0.800000,Max=0.800000),Z=(Min=-1.000000,Max=1.000000))
        Name="BeamEmitter1"
    End Object
    Emitters(0)=BeamEmitter'BeamEmitter1'
    AutoDestroy=true
}

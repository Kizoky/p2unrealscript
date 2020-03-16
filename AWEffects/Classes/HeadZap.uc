///////////////////////////////////////////////////////////////////////////////
// HeadZap
// Life force line flowing towards awbosseye
// 
///////////////////////////////////////////////////////////////////////////////
class HeadZap extends P2Emitter;

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter4
         BeamDistanceRange=(Min=120.000000,Max=120.000000)
         LowFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         LowFrequencyPoints=5
         HighFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=1.000000,Max=3.000000))
         UseColorScale=True
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
         ColorScaleRepeats=1.000000
         FadeOut=True
         MaxParticles=2
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=3.000000,Max=10.000000))
         Texture=Texture'nathans.Skins.lightning6'
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=250.000000,Max=300.000000),Y=(Min=300.000000,Max=300.000000),Z=(Min=100.000000,Max=100.000000))
         Name="BeamEmitter4"
     End Object
     Emitters(0)=BeamEmitter'AWEffects.BeamEmitter4'
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class ZFloatZapMini extends ZFloatZap;

defaultproperties
{
     HealthToSap=3
     zapwait=0.300000
     Begin Object Class=BeamEmitter Name=BeamEmitter6
         BeamDistanceRange=(Min=120.000000,Max=120.000000)
         LowFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         LowFrequencyPoints=5
         HighFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=1.000000,Max=3.000000))
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,R=255))
         ColorScaleRepeats=1.000000
         FadeOut=True
         MaxParticles=5
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=40.000000))
         Texture=Texture'nathans.Skins.lightning5'
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=250.000000,Max=300.000000),Y=(Min=300.000000,Max=300.000000),Z=(Min=100.000000,Max=100.000000))
         Name="BeamEmitter6"
     End Object
     Emitters(0)=BeamEmitter'AWEffects.BeamEmitter6'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter131
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,R=255))
         FadeOut=True
         MaxParticles=8
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.blast1'
         LifetimeRange=(Min=0.500000,Max=0.600000)
         Name="SpriteEmitter131"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter131'
     AmbientSound=Sound'WeaponSounds.tazer_hit'
}

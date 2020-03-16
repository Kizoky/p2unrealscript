///////////////////////////////////////////////////////////////////////////
// Same as BloodSpoutFeeder but it doesn't cost as much processor time
///////////////////////////////////////////////////////////////////////////
class BloodSpoutFeederCheap extends BloodSpoutFeeder;

defaultproperties
{
     ArcMax=2
     QuantityPerHit=250.000000
     Quantity=5.000000
     Begin Object Class=StripEmitter Name=StripEmitter10
         Acceleration=(Z=-2000.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,A=255))
         FadeOut=True
         FadeInEndTime=0.300000
         FadeIn=True
         MaxParticles=20
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScaleRepeats=3.000000
         StartSizeRange=(X=(Min=0.500000,Max=2.500000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.pour1'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000),Z=(Min=300.000000,Max=300.000000))
         Name="StripEmitter10"
     End Object
     Emitters(0)=StripEmitter'StripEmitter10'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter53
         Acceleration=(Z=-1800.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,A=255))
         FadeOutStartTime=1.100000
         FadeOut=True
         MaxParticles=20
         SpinParticles=True
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.600000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=0.800000,Max=1.800000),Y=(Min=0.800000,Max=1.800000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.drips1'
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         UseRandomSubdivision=True
         SecondsBeforeInactive=100.000000
         LifetimeRange=(Min=1.300000,Max=1.600000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
         Name="SpriteEmitter53"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter53'
}

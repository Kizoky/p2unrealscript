//=============================================================================
// CowChargeDust
//=============================================================================
class CowChargeDust extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter76
         UseColorScale=True
         ColorScale(0)=(Color=(B=58,G=84,R=126))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=61,G=100,R=182))
         MaxParticles=20
         StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-10.000000,Max=10.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=30.000000,Max=65.000000))
         InitialParticlesPerSecond=20.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=1.000000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Max=30.000000))
         Name="SpriteEmitter76"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter76'
     AutoDestroy=True
}

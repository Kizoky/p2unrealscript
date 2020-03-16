///////////////////////////////////////////////////////////////////////////////
// Thick fluid
///////////////////////////////////////////////////////////////////////////////
class ButtHitEffects extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter113
         Acceleration=(Z=-80.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=192,G=128,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=255))
         FadeOut=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=25.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.300000,Max=2.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=-250.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Max=50.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         Name="SpriteEmitter113"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter113'
     AutoDestroy=True
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     Mass=-50.000000
}

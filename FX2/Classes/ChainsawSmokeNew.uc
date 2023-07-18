///////////////////////////////////////////////////////////////////////////////
// ChainsawSmokeNew
// smoke fx for chainsaw.
///////////////////////////////////////////////////////////////////////////////
class ChainsawSmokeNew extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitterCS
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.4)) //0.2
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
		 SizeScale(0)=(RelativeSize=0.500000) 
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=7.000000)) 
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.2300000,Max=0.250000)
         StartVelocityRange=(X=(Min=-28.000000,Max=28.000000),Y=(Min=-28.000000,Max=28.000000),Z=(Min=-28.000000,Max=28.000000))
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="SpriteEmitterCS"
     End Object
     Emitters(0)=SpriteEmitter'FX2.SpriteEmitterCS'
     AutoDestroy=True
}

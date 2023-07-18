///////////////////////////////////////////////////////////////////////////////
// PistolPuff
// smoke that the pistol makes--for the moment.
///////////////////////////////////////////////////////////////////////////////
class EDPistolPuff extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=EDPuff00
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         //StartSizeRange=(X=(Min=2.500000,Max=3.000000))
		 StartSizeRange=(X=(Min=12.50000,Max=15.00000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.500000)
         //StartVelocityRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Min=-8.000000,Max=8.000000))
		 StartVelocityRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-40.000000,Max=40.000000))
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="EDPuff00"
     End Object
     Emitters(0)=SpriteEmitter'EDPuff00'
     AutoDestroy=True
}

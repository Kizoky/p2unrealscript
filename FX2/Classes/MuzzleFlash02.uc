//////////////////////////////////////////////////////////////////////
// 12/2/13 MrD	- New MuzzleFlash to replace old staticmesh ones... //
//////////////////////////////////////////////////////////////////////
class MuzzleFlash02 extends MuzzleFlashEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter99
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.450000))
         StartSpinRange=(X=(Max=1.800000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=3.350000)
         SizeScale(1)=(RelativeTime=3.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=4.000000,Max=6.000000))
         InitialParticlesPerSecond=30.000000
         AutomaticInitialSpawning=False
         Texture=Texture'nathans.Skins.expl1color'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.300000)
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="SpriteEmitter99"
     End Object
     Emitters(0)=SpriteEmitter'FX2.SpriteEmitter99'
     AutoDestroy=True
}

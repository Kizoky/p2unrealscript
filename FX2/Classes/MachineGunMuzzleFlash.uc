//////////////////////////////////////////////////////////////////////
// 12/2/13 MrD	- New MuzzleFlash to replace old staticmesh ones... //
//////////////////////////////////////////////////////////////////////
class MachineGunMuzzleFlash extends xMuzzleFlashEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter69
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=3.500000,Max=4.000000))
         InitialParticlesPerSecond=15.000000
         AutomaticInitialSpawning=False
         Texture=Texture'nathans.Skins.expl1color'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.300000)
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="SpriteEmitter69"
     End Object
     Emitters(0)=SpriteEmitter'FX2.SpriteEmitter69'
     AutoDestroy=True
}

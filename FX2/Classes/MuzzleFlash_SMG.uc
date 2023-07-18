//=====================================================================================
// MuzzleFlash_SMG
// Created by Man Chrzan for xPatch 2.0
//
// Special emitter for SMG and Glock, with 2 particles and 1x4 subdivisions.
//=====================================================================================
class MuzzleFlash_SMG extends xMuzzleFlashEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitterSMG
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
         StartSizeRange=(X=(Min=9.500000,Max=20.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.expl1color'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.025000,Max=0.075000)
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="SpriteEmitterSMG"
     End Object
	 Emitters(0)=SpriteEmitter'FX2.SpriteEmitterSMG'
     AutoDestroy=True
}

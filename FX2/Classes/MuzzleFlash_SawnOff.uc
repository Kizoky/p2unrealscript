//=====================================================================================
// MuzzleFlash_SawnOff
// Created by Man Chrzan for xPatch 2.0
//
// Special emitter for Sawn-Off, with 2 particles.
// (MaxParticles is a const so it can't be setup through weapon, sadly)
//=====================================================================================
class MuzzleFlash_SawnOff extends xMuzzleFlashEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitterSawnOff
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
         Texture=Texture'Timb.muzzleflash.shotgun_corona'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.025000,Max=0.075000)
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="SpriteEmitterSawnOff"
     End Object
	 Emitters(0)=SpriteEmitter'FX2.SpriteEmitterSawnOff'
	 Emitters(1)=SpriteEmitter'FX2.SpriteEmitter4'	// Smoke
     Emitters(2)=SpriteEmitter'FX2.SpriteEmitter5'	// Smoke 2
     AutoDestroy=True
}

Class MuzzleFlashCatBlood extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=CatBloodEmitter2
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.450000))
         StartSpinRange=(X=(Max=1.800000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=28.350000)
         SizeScale(1)=(RelativeTime=28.000000,RelativeSize=28.000000)
         StartSizeRange=(X=(Min=1.000000,Max=1.000000))
         InitialParticlesPerSecond=30.000000
         AutomaticInitialSpawning=False
		 DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.muzzleflashes.bloodmuzzleflash'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.030000,Max=0.030000)
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="CatBloodEmitter2"
     End Object
	 Emitters(0)=SpriteEmitter'CatBloodEmitter2'
     AutoDestroy=True
}
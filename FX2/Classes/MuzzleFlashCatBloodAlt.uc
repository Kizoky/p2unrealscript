class MuzzleFlashCatBloodAlt extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=CatBloodEmitter
         FadeOut=True
         MaxParticles=4
         RespawnDeadParticles=False
		 CoordinateSystem=PTCS_Relative
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=11.000000,Max=19.000000))
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodimpacts'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         Name="CatBloodEmitter"
     End Object
     Emitters(0)=SpriteEmitter'CatBloodEmitter'
     AutoDestroy=true
	 LifeSpan=2.0
}
///////////////////////////////////////////////////////////////////////////////
// Muzzle flash for Weapons
///////////////////////////////////////////////////////////////////////////////
class MuzzleSmoke03 extends MuzzleFlashEmitter;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter96
         
		 UseColorScale=True
         ColorScale(0)=(Color=(B=76,G=76,R=76))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=76,G=76,R=76))
         FadeOut=True
         CoordinateSystem=PTCS_Relative
         RespawnDeadParticles=False
         SpinParticles=True
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=60.000000))
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.wispsmoke'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         UseRandomSubdivision=True
         LifetimeRange=(Min=0.600000,Max=0.800000)
		 MaxParticles=1
         SpinsPerSecondRange=(X=(Max=0.200000))
         InitialParticlesPerSecond=100.000000
         Name="SpriteEmitter96"
		 
         SecondsBeforeInactive=0.000000
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
		 
     End Object
     Begin Object Class=SpriteEmitter Name=SpriteEmitter97
         UseColorScale=True
         ColorScale(0)=(Color=(B=10,G=10,R=10))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=10,G=10,R=10))
         FadeOut=True
         FadeIn=True
         CoordinateSystem=PTCS_Relative
         RespawnDeadParticles=False
         UseRotationFrom=PTRS_Actor
         SpinParticles=True
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
         StartSizeRange=(X=(Max=120.000000))
         UniformSize=True
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'xPatchTex.FX.SmokePuff01'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         UseRandomSubdivision=True
         LifetimeRange=(Min=0.600000,Max=0.800000)
		 MaxParticles=1
         SpinsPerSecondRange=(X=(Max=0.200000))
         InitialParticlesPerSecond=100.000000
		 
		 SecondsBeforeInactive=0.000000
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
		 
         Name="SpriteEmitter97"
     End Object
	 Emitters(0)=SpriteEmitter'FX2.SpriteEmitter96'
	 Emitters(1)=SpriteEmitter'FX2.SpriteEmitter97'
	 AutoDestroy=True
}

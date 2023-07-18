///////////////////////////////////////////////////////////////////////////////
// Dynamite Sparkler
///////////////////////////////////////////////////////////////////////////////
class DynamiteSparklerFPS extends P2Emitter;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter292
		 ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=98))
         FadeOut=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         UseSizeScale=True
         SizeScale(0)=(RelativeSize=0.4)
         SizeScale(1)=(RelativeTime=0.5,RelativeSize=1.0)
         SizeScale(2)=(RelativeTime=1.0)
         StartSizeRange=(X=(Min=1.0,Max=4.0))
         UniformSize=True
         DrawStyle=PTDS_Brighten
         Texture=Texture'xPatchTex.FX.FuseSparkler'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.0
         LifetimeRange=(Min=0.2,Max=0.3)
		 StartVelocityRange=(Y=(Min=0.0,Max=-85.0),Z=(Min=0.0,Max=85.0))
         VelocityLossRange=(Y=(Min=5.0,Max=5.0),Z=(Min=5.0,Max=5.0))
         Name="SpriteEmitter292"
     End Object
	 Emitters(0)=SpriteEmitter'SpriteEmitter292'
     AutoDestroy=True
     LifeSpan=1.500000
     AmbientSound=Sound'WeaponSounds.molotov_lightloop'
     SoundRadius=128.000000
     SoundVolume=255
}

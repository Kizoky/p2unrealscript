///////////////////////////////////////////////////////////////////////////////
// Dynamite Sparkler
///////////////////////////////////////////////////////////////////////////////
class DynamiteSparkler extends P2Emitter;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter67
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=98))
         FadeOut=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartLocationOffset=(Y=9.000000)
         UseSizeScale=True
         SizeScale(0)=(RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.250000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=6.000000,Max=12.000000))
         UniformSize=True
         DrawStyle=PTDS_Brighten
         Texture=Texture'xPatchTex.FX.FuseSparkler'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.100000,Max=0.200000)
		 StartVelocityRange=(Y=(Min=0.0,Max=125.0),Z=(Min=0.0,Max=-75.0))
         VelocityLossRange=(Y=(Min=5.0,Max=5.0),Z=(Min=5.0,Max=5.0))
         Name="SpriteEmitter67"
     End Object
	 Emitters(0)=SpriteEmitter'SpriteEmitter67'
     AutoDestroy=True
     bTrailerSameRotation=True
     bReplicateMovement=True
     Physics=PHYS_Trailer
     LifeSpan=8.000000
}

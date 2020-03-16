///////////////////////////////////////////////////////////////////////////////
// MolotovWickFire
// 
// Fire for the cloth wick on a molotov cocktail
//
///////////////////////////////////////////////////////////////////////////////
class DynamiteSparkler extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         Acceleration=(Z=-100.000000)
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=98))
         FadeOut=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartLocationOffset=(Y=9.000000)
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-1.000000,Max=1.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.300000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=2.000000,Max=6.000000))
         UniformSize=True
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=100.000000))
         Name="SpriteEmitter5"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter5'
     AutoDestroy=True
     bTrailerSameRotation=True
     bReplicateMovement=True
     Physics=PHYS_Trailer
     LifeSpan=20.000000
}

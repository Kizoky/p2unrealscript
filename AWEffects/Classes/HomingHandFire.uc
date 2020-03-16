///////////////////////////////////////////////////////////////////////////////
// HomingHandFire
// Just visual--no actual burning
///////////////////////////////////////////////////////////////////////////////
class HomingHandFire extends StraightHandFire;

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
         UseColorScale=True
         ColorScale(0)=(Color=(B=50,G=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=10
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-10.000000,Max=10.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=30.000000,Max=50.000000))
         Texture=Texture'nathans.Skins.firegroup3'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=200.000000,Max=300.000000))
         Name="SuperSpriteEmitter6"
     End Object
     Emitters(0)=SuperSpriteEmitter'AWEffects.SuperSpriteEmitter6'
}

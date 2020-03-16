///////////////////////////////////////////////////////////////////////////////
// NapalmStarterFollow
//
// Extends emitter because this thing doesn't actually cause damage, it just sets fires.
///////////////////////////////////////////////////////////////////////////////
class NapalmStarterFollow extends FireStarterFollow;


defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter3
		SecondsBeforeInactive=0.0
         FadeOutStartTime=1.000000
         FadeOut=True
         MaxParticles=20
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=45.000000))
		 DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.fireblue'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.600000,Max=1.200000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=30.000000,Max=100.000000))
         Name="SuperSpriteEmitter3"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter3'
	 VelMag=800
}

class SmokeEmitterMap extends Emitter;

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SpriteEmitter18
		Acceleration=(X=30.000000,Y=-10.000000,Z=-20.000000)
		FadeOutStartTime=1.200000
		FadeOut=True
		FadeInEndTime=1.000000
		FadeIn=True
		MaxParticles=15
		StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-40.000000,Max=40.000000))
		SpinParticles=True
		SpinsPerSecondRange=(X=(Max=0.200000))
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=0.300000)
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		StartSizeRange=(X=(Min=80.000000))
		DrawStyle=PTDS_Brighten
		Texture=Texture'nathans.Skins.smoke5'
		TextureUSubdivisions=1
		TextureVSubdivisions=4
		BlendBetweenSubdivisions=True
		LifetimeRange=(Min=2.000000,Max=2.000000)
		StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=60.000000,Max=100.000000))
		Name="SpriteEmitter18"
	End Object
	Emitters(0)=SpriteEmitter'SpriteEmitter18'
	Texture=Texture'PostEd.Icons_256.SmokeEmitter'
}

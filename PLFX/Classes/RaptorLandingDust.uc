//=============================================================================
// DustHitPuff
//
// Used in the place of blood
//=============================================================================
class RaptorLandingDust extends P2Emitter;

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SpriteEmitter68
		UseColorScale=True
		ColorScale(0)=(Color=(B=58,G=84,R=126))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=61,G=100,R=182))
		MaxParticles=20
		RespawnDeadParticles=False
		SpinParticles=True
		SpinsPerSecondRange=(X=(Max=0.200000))
		StartSpinRange=(X=(Max=1.000000))
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=0.300000)
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		StartSizeRange=(X=(Min=60.000000,Max=120.000000))
		InitialParticlesPerSecond=100.000000
		AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
		Texture=Texture'nathans.Skins.smoke5'
		TextureUSubdivisions=1
		TextureVSubdivisions=4
		BlendBetweenSubdivisions=True
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=0.350000,Max=0.750000)
		StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-200.000000,Max=200.000000))
		VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
		StartLocationRange=(X=(Min=-60,Max=60),Y=(Min=-60,Max=60))
		Name="SpriteEmitter68"
	End Object
	Emitters(0)=SpriteEmitter'SpriteEmitter68'
	AutoDestroy=true
}

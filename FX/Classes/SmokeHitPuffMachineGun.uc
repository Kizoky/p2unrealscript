//=============================================================================
// SmokeHitPuffMachineGun.
//=============================================================================
class SmokeHitPuffMachineGun extends SmokeHitPuff;

defaultproperties
{
 	 Begin Object Class=SpriteEmitter Name=SpriteEmitter10
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(B=58,G=84,R=126))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=61,G=100,R=182))
		MaxParticles=2
        RespawnDeadParticles=False
		SpinParticles=True
		SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=0.300000)
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		StartSizeRange=(X=(Min=30.000000,Max=45.000000))
        InitialParticlesPerSecond=15.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
		BlendBetweenSubdivisions=True
		LifetimeRange=(Min=0.700000,Max=1.100000)
		StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000),)
		VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
		Name="SpriteEmitter10"
	 End Object
	 Emitters(0)=SpriteEmitter'Fx.SpriteEmitter10'
	 AutoDestroy=true
	 velmax=150
	 timemax=150
	 timediv=100
	 timeminratio=0.3
	TransientSoundRadius=50
	CullDistance=3500.0
}

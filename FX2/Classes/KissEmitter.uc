///////////////////////////////////////////////////////////////////////////////
// KissEmitter
// Smoochy smoochy stuff for valentines day <3
///////////////////////////////////////////////////////////////////////////////
class KissEmitter extends P2Emitter;

var() sound KissSound;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
Begin:
	PlaySound(KissSound,,1.0,,,GetRandPitch(),true);
	Sleep(1.5);
	GotoState('Fading');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Fading
{
	event BeginState()
	{
		local int i;
		
		for (i=0; i<Emitters.Length; i++)
		{
			Emitters[i].ParticlesPerSecond=0;
			Emitters[i].InitialParticlesPerSecond=0;
		}
	}
	
Begin:
	Sleep(1.0);
	Destroy();
}

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=HeartsFX2
		Acceleration=(X=1.000000,Y=1.000000,Z=200.000000)
		FadeOut=True
		FadeIn=True
		StartLocationRange=(X=(Min=-70.000000,Max=70.000000),Y=(Min=-70.000000,Max=70.000000),Z=(Min=-5.000000,Max=15.000000))
		SphereRadiusRange=(Min=12.000000,Max=555.000000)
		UseRotationFrom=PTRS_Normal
		SpinParticles=True
		SpinCCWorCW=(X=5.000000,Y=5.000000,Z=5.000000)
		SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=1.000000,Max=1.000000),Z=(Min=-5.000000,Max=1.000000))
		StartSpinRange=(X=(Min=1.000000,Max=3.000000),Y=(Min=1.000000,Max=3.000000),Z=(Min=1.000000,Max=3.000000))
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=0.180000)
		SizeScale(1)=(RelativeTime=0.000000,RelativeSize=0.080000)
		StartSizeRange=(X=(Min=5.000000,Max=6.000000),Y=(Min=5.000000,Max=6.000000),Z=(Min=6.000000,Max=6.500000))
		UniformSize=True
		ParticlesPerSecond=10.000000
		InitialParticlesPerSecond=10.000000
		AutomaticInitialSpawning=False
		Texture=Texture'P2R_Tex_D.Env.heart'
		LifetimeRange=(Min=0.000000,Max=0.900000)
		StartVelocityRange=(X=(Min=-110.000000,Max=122.000000),Y=(Min=-110.000000,Max=150.000000),Z=(Min=40.000000,Max=2.000000))
		StartVelocityRadialRange=(Min=-5.000000,Max=5.000000)
		VelocityLossRange=(X=(Min=-1.000000))
		AddVelocityMultiplierRange=(Z=(Min=-9.000000,Max=-1.000000))
		AutoDestroy=True
		Name="HeartsFX2"
	End Object
	Begin Object Class=SpriteEmitter Name=PinkFX2
		Acceleration=(Z=300.000000)
		UseCollision=True
		UseColorScale=True
		ColorScale(0)=(Color=(B=102,G=102,R=102,A=102))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=106,R=157))
		FadeOut=True
		FadeIn=True
		MaxParticles=8
		StartLocationOffset=(Z=-30.000000)
		StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000))
		StartMassRange=(Max=6.000000)
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=0.070000)
		SizeScale(1)=(RelativeTime=0.000000,RelativeSize=0.600000)
		StartSizeRange=(X=(Max=70.000000),Y=(Max=70.000000),Z=(Max=70.000000))
		ParticlesPerSecond=4.000000
		InitialParticlesPerSecond=4.000000
		Texture=Texture'GenFX.LensFlar.DotPink'
		LifetimeRange=(Min=2.000000,Max=4.0)
		StartVelocityRange=(X=(Min=-250.000000,Max=250.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Min=90.000000,Max=200.000000))
		AutoDestroy=True
		RespawnDeadParticles=false
	Name="PinkFX2"
	End Object
	Emitters(0)=SpriteEmitter'PinkFX2'
	Emitters(1)=SpriteEmitter'HeartsFX2'
	KissSound=Sound'MiscSounds.People.Kissing'
	AutoDestroy=True
}
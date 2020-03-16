///////////////////////////////////////////////////////////////////////////
// Feeder that attaches to other objects to be poured out
///////////////////////////////////////////////////////////////////////////
class GonorrheaPourFeeder extends UrinePourFeeder;

///////////////////////////////////////////////////////////////////////////
// The fluid is hitting a pawn. 
///////////////////////////////////////////////////////////////////////////
function HittingPawn(FPSPawn fpawn, vector HitLocation)
{
	local LambController lambc;

	lambc = LambController(fpawn.Controller);

	// Only happens if guy is still alive
	if(lambc != None)
	{
		// Set me to dripping in pee
		lambc.HitWithFluid(MyType, HitLocation);

		// True at the end, will ensure that everyone hit by this will 
		// throw up, if they can.
		lambc.BodyJuiceSquirtedOnMe(P2Pawn(MyOwner), true);
	}

	if(fpawn.MyBodyFire != None)
	{
		MakeSteam();
		MySteam.SetLocation(HitLocation);

		// Put out the fire
		fpawn.MyBodyFire.TakeDamage
		(
			PAWN_PUT_OUT*Quantity,
			Pawn(MyOwner),
			HitLocation,
			vect(0, 0, 0),
			class'ExtinguishDamage'
		);
	}
}

///////////////////////////////////////////////////////////////////////////
// No variance in gonorrhea
///////////////////////////////////////////////////////////////////////////
function VaryStream(float DeltaTime)
{
}

defaultproperties
{
    Begin Object Class=StripEmitter Name=StripEmitter0
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(A=255,R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255,G=255,B=255))
        FadeOut=True
        Acceleration=(Z=-1800.000000)
        MaxParticles=17
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.500000,Max=2.500000))
		DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.pukepour'
        LifetimeRange=(Min=0.600000,Max=0.600000)
        StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000),Z=(Min=300.000000,Max=300.000000))
        Name="StripEmitter0"
    End Object
    Emitters(0)=StripEmitter'Fx.StripEmitter0'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1600.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255,R=200))
        FadeOutStartTime=1.100000
        FadeOut=True
        MaxParticles=25
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.600000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.800000,Max=1.800000),Y=(Min=0.800000,Max=1.800000))
        InitialParticlesPerSecond=0.000000
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.pukesplat'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.300000,Max=1.600000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'Fx.SpriteEmitter1'
    MyType=FLUID_TYPE_Gonorrhea
	SplashClass = Class'PukeSplashEmitter'
	TrailClass = Class'PukeTrail'
	TrailStarterClass = Class'PukeTrailStarter'
	PuddleClass = Class'PukePuddle'
	bCollideActors=true
	QuantityPerHit=10
	SpawnDripTime=0.15
	TimeToMakePuddle=0.1
	bCanHitActors=true
	MomentumTransfer=1.0
	InitialPourSpeed=600
	InitialSpeedZPlus=500
	SpeedVariance=15
	Quantity=40
	LifeSpan=0
    AutoDestroy=true
	ArcMax=8
}

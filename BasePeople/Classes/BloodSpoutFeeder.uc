///////////////////////////////////////////////////////////////////////////
// Feeder that attaches to other objects to be poured out (like a gas tank)
///////////////////////////////////////////////////////////////////////////
class BloodSpoutFeeder extends UrinePourFeeder;

var float PumpingTime;		// timer to get track of pumping (controls flow)
var float PourSpeedBase;	// starting speed
var float PourSpeedRatio;	// ratio of time passed added to base to make total speed
var float PourReduction;	// how much the pour ratio is reduced over time

var vector RotationOffset;	// offset for SetDir--set by a punctured head
var vector DirOffset;		// direction offset to be used in set dir--set on the fly for a good wiggle effect

var Sound SplashingSound;

const END_TIME = 0.8;

///////////////////////////////////////////////////////////////////////////
// Don't make them dirty things or put out fires.. it's too confusing
// and people won't get it
///////////////////////////////////////////////////////////////////////////
function int FeederHitActor(Actor Other, vector HitLocation, vector HitNormal,
						vector FeederStart, vector FeederEnd, float DeltaTime)
{
	return 0;
}

///////////////////////////////////////////////////////////////////////////
// The fluid is hitting a pawn. 
// Too costly for very little gain
///////////////////////////////////////////////////////////////////////////
function HittingPawn(FPSPawn fpawn, vector HitLocation)
{
}

///////////////////////////////////////////////////////////////////////////
// Too costly for very little gain
///////////////////////////////////////////////////////////////////////////
function HittingOwner(vector Dir)
{
}

///////////////////////////////////////////////////////////////////////////
// Make the emitter shoot out of Rotation
///////////////////////////////////////////////////////////////////////////
function SetDir(vector newloc, vector startdir, optional float velmag, optional bool bInitArc)
{
	startdir += RotationOffset;
	startdir += DirOffset;
	Super.SetDir(newloc, startdir, velmag, bInitArc);
}

///////////////////////////////////////////////////////////////////////////////
// Check for collisions and move particles
///////////////////////////////////////////////////////////////////////////////
function SetStartSpeeds(float SpeedBase, float RealLife, optional vector StartRotationOffset)
{
	PourSpeedBase = SpeedBase;
	PourSpeedRatio = PourSpeedBase*3;

	RotationOffset = StartRotationOffset;

	PourReduction = PourSpeedBase/RealLife;

	LifeSpan = RealLife + 2;
}

///////////////////////////////////////////////////////////////////////////////
// Check for collisions and move particles
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	PumpingTime += DeltaTime;

	if(PumpingTime > END_TIME)
		PumpingTime = 0;

	DirOffset.x = sin(DeltaTime);

	InitialPourSpeed = PumpingTime*PourSpeedRatio + PourSpeedBase;
	InitialSpeedZPlus = InitialPourSpeed;

	PourSpeedRatio -= PourReduction*DeltaTime;

	If(PourSpeedRatio <= 0)
		ToggleFlow(0, false);
}

///////////////////////////////////////////////////////////////////////////////
// officialy unhook us
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(PersonPawn(MyOwner) != None)
	{
		PersonPawn(MyOwner).RemoveFluidSpout();
		PersonPawn(MyOwner).FluidSpout=None;
	}

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// starting up
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Starting
{
	ignores CheckForFluidHit;

	function Timer()
	{
		AmbientSound=SplashingSound;
		SetOwner(None);

		Super.Timer();
	}
}

defaultproperties
{
    Begin Object Class=StripEmitter Name=StripEmitter0
        Acceleration=(Z=-2000.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(A=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255))
        FadeInEndTime=0.300000
        FadeIn=True
	    FadeOut=True
        MaxParticles=20
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=0.500000,Max=2.500000))
		DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.pour1'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000),Z=(Min=300.000000,Max=300.000000))
        Name="StripEmitter0"
    End Object
    Emitters(0)=StripEmitter'StripEmitter0'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        Acceleration=(Z=-1800.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(A=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255))
        FadeOutStartTime=1.100000
        FadeOut=True
        MaxParticles=20
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.600000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.800000,Max=1.800000),Y=(Min=0.800000,Max=1.800000))
        InitialParticlesPerSecond=0.000000
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.drips1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        SecondsBeforeInactive=100.000000
        LifetimeRange=(Min=1.300000,Max=1.600000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'
    AutoDestroy=true
    MyType=FLUID_TYPE_Blood
	SplashClass = Class'BloodSplashEmitter'
	TrailClass = Class'BloodTrail'
	TrailStarterClass = Class'BloodTrailStarter'
	PuddleClass = Class'BloodPuddle'
	bCanHitActors=false
	QuantityPerHit=8
	SpawnDripTime=0.15
	MomentumTransfer=1.0
	SpeedVariance=40
	Quantity=30

	SplashingSound = Sound'WeaponSounds.blood_squirt_loop'
	ArcMax=5
}

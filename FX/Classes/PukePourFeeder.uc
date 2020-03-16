///////////////////////////////////////////////////////////////////////////
// Feeder that attaches to other objects to be poured out (like a gas tank)
///////////////////////////////////////////////////////////////////////////
class PukePourFeeder extends UrinePourFeeder;

var Sound SplashingSound;
var BodyPart HeadOwner;

const VEL_Z_DOT_PLUS = 20;

simulated function Destroyed()
{
	// Null out head's puke stream
	if (HeadOwner != None)
		HeadOwner.ZeroPukeFeeder(Self);
		
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////
// The fluid is hitting a pawn. 
///////////////////////////////////////////////////////////////////////////
function HittingPawn(FPSPawn fpawn, vector HitLocation)
{
	if(LambController(fpawn.Controller) != None)
	{
		LambController(fpawn.Controller).BodyJuiceSquirtedOnMe(P2Pawn(MyOwner), true);
	}
}

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
	local int i;
	local vector dir;
	local float addzmag, usevelmag;
	local vector ownervel;

	// Save our collision location each time--could be different than our visual location
	CollisionStart = newloc;

	dir = Normal(startdir);

	// find a factor of how inline with velocity motion, this direction is
	usevelmag = VSize(MyOwner.Velocity);
	if(usevelmag > 0)
		addzmag = ((VEL_Z_DOT_PLUS*(MyOwner.Velocity Dot dir))/usevelmag);
	else
		addzmag = 0;
	addzmag+= InitialSpeedZPlus;
	
	ownervel = -0.8*MyOwner.Velocity;//VSize(MyOwner.Velocity)*(vector(StartRotation + rotator(MyOwner.Velocity)));
	// record velocity for collision particles
	CollisionVelocity = InitialPourSpeed*dir - ownervel;
	CollisionVelocity.z+= addzmag;

	for(i=0; i<Emitters.length; i++)
	{
		Emitters[i].StartVelocityRange.X.Max = 	InitialPourSpeed*dir.x + -ownervel.x ;
		Emitters[i].StartVelocityRange.X.Min = 	Emitters[i].StartVelocityRange.X.Max;
		Emitters[i].StartVelocityRange.Y.Max = 	InitialPourSpeed*dir.y + -ownervel.y ;
		Emitters[i].StartVelocityRange.Y.Min = 	Emitters[i].StartVelocityRange.Y.Max;
		Emitters[i].StartVelocityRange.Z.Max = 	InitialPourSpeed*dir.z + -ownervel.z + addzmag;
		Emitters[i].StartVelocityRange.Z.Min = 	Emitters[i].StartVelocityRange.Z.Max;
	}
	
	if(Emitters.Length > 1)
	{
		Emitters[1].StartVelocityRange.X.Max += (SpeedVariance);
		Emitters[1].StartVelocityRange.X.Min -= (SpeedVariance);
		Emitters[1].StartVelocityRange.Y.Max += (SpeedVariance);
		Emitters[1].StartVelocityRange.Y.Min -= (SpeedVariance);
		Emitters[1].StartVelocityRange.Z.Max += (SpeedVariance);
		Emitters[1].StartVelocityRange.Z.Min -= (SpeedVariance);
	}

	if(bInitArc)
		EstimateArc();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
	//log(self@"toggle flow",'Debug');
	if(!bIsOn)
		AmbientSound=None;

	Super.ToggleFlow(TimeToStop, bIsOn);
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

		Super.Timer();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// fading out
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dying
{
	ignores Tick;

	function Timer()
	{
		//SeverLinks();
		//log("KILLING THIS FEEDER "$self);
		Destroy();
	}

	function BeginState()
	{
		SetTimer(2.0, false); // time to kill off this actor
	}
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
        StartSizeRange=(X=(Min=1.000000,Max=10.000000))
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
        Texture=Texture'nathans.Skins.pukesplat'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.300000,Max=1.600000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'Fx.SpriteEmitter1'
    MyType=FLUID_TYPE_Puke
	SplashClass = Class'PukeSplashEmitter'
	TrailClass = Class'PukeTrail'
	TrailStarterClass = Class'PukeTrailStarter'
	PuddleClass = Class'PukePuddle'
	bCollideActors=true
	QuantityPerHit=8
	SpawnDripTime=0.15
	TimeToMakePuddle=0.1
	bCanHitActors=true
	MomentumTransfer=1.0
	InitialPourSpeed=300
	InitialSpeedZPlus=0
	SpeedVariance=15
	Quantity=30
	LifeSpan=8
    AutoDestroy=true
	SplashingSound = Sound'MiscSounds.People.vomit_loop'
	ArcMax=5
}

///////////////////////////////////////////////////////////////////////////
// Feeder specific to dead bodies. This just shoots straight
// down to the ground and makes puddles/trails. There is no
// visual manifestation of the feeder/stream itself. You can
// only see it as the puddles/trails it makes.
///////////////////////////////////////////////////////////////////////////
class BloodBodyFeeder extends FluidFeeder;

const DOWN_Z_TEST	=	200;
const DOWN_VEL		=	100;

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function CapChildPuddleRadii()
{
	local float FirstRadMax;
	local FluidPuddle gp;
	local Fluid checkfluid;
	local int ct;

//	log("looking forward ");
	// Save the radius of the puddle we're pouring into.
	FirstRadMax = FPuddle.UseColRadius;
	checkfluid = FPuddle.Next;
	// With this pour feeder ending, go to the first puddle (assuming there is one)
	// record it's radius, and then move from it down through any child puddles.
	// For each of those whose radius maxes are larger than the parent's, cap them.
	while(!checkfluid.bDeleteMe
		&& checkfluid != None
		&& ct < 5000)
	{
//		log("checkfluid "$self);
		if(checkfluid.IsA('FluidPuddle'))
		{
//			log("found a puddle");
			if(FluidPuddle(checkfluid).RadMax > FirstRadMax)
			{
//				log("too far over.. capping");
				FluidPuddle(checkfluid).RadMax = FirstRadMax;
			}
		}
		checkfluid = checkfluid.Next;
		ct++;
	}
//	log("end of looking forward");
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
//	log("stopping the pour feeder "$self);

	if(FPuddle != None)
		CapChildPuddleRadii();

	Super.ToggleFlow(TimeToStop, bIsOn);
}

///////////////////////////////////////////////////////////////////////////////
// Check for collisions and move particles
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	local vector vel;
	local int i, k, j;
	local bool tracehit;
	local vector StartPos, EndPos;
//	local vector HitLocation, HitNormal;

	// remove quantity if it's been used
	if(!bInfiniteQuantity
		&& Quantity > 0)
	{
		Quantity -= QuantityPerHit*DeltaTime;
		if(Quantity < 0)
			ToggleFlow(0, false);
	}

	// perform collisions
	//FSplash.TurnOffSplash();

	// check section between spout and owner
	StartPos = Location;
	EndPos = Location;
	StartPos.z += DOWN_Z_TEST;
	EndPos.z -= DOWN_Z_TEST;
	vel.z=-DOWN_VEL;

	if(!FeederTrace(StartPos, EndPos, vel, DeltaTime, 0))
		LastHitPos = EndPos;
}

defaultproperties
{
    MyType=FLUID_TYPE_Blood
	SplashClass = None
	TrailClass = Class'BloodTrail'
	TrailStarterClass = Class'BloodTrailStarter'
	PuddleClass = Class'BloodPuddle'
	QuantityPerHit=8
	SpawnDripTime=0.15
	MomentumTransfer=1.0
	Quantity=10
	LifeSpan=10
	StartingTime=1.0
}

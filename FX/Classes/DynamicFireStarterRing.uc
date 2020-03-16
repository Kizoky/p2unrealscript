///////////////////////////////////////////////////////////////////////////////
// DynamicFireStarterRing
//
// Test for ground edge and changes size based on not having a vialbe surface
// 
///////////////////////////////////////////////////////////////////////////////
class DynamicFireStarterRing extends FireStarterRing;

var float UseRadius;
var float GrowTime;
var float CheckTime;
var vector CheckPoint;
var float FirePuddleTime;

const GROUND_CHECK_Z	=	40;
const MIN_RAD			=	50;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	RadVel = UseRadius/GrowTime; // Calc in case these vals are modified in default properties
	Emitters[0].StartLocationRange.X.Max=0;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Burning, checking ground for area to support it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state NowBurning
{
	///////////////////////////////////////////////////////////////////////////////
	// Check the ground below this point and modify the radius/lifespan based on
	// if the ground is there or not
	///////////////////////////////////////////////////////////////////////////////
	function CheckGround(vector CheckP)
	{
		local Actor HitActor;
		local vector HitLocation, HitNormal, endp, startp, MeasureV;
		local bool bRecalcRadius;

		if(UseRadius > MIN_RAD)
		{
			// Trace from the center to the edge, and make sure you don't hit
			// anything.. if so, retract the radius accordingly
			HitActor = Trace(HitLocation, HitNormal, CheckP, Location, true);
			if(HitActor != None)
				bRecalcRadius=true;
			else	// Trace down from the edge, below the ground, and hope you
				// hit something to burn on .. if not, then you'll have to retract
				// the radius here too.
			{
				endp = CheckP;
				endp.z -= GROUND_CHECK_Z;
				HitActor = Trace(HitLocation, HitNormal, endp, CheckP, true);
				// If it didn't hit anything,then trace back to the start point and
				// hopefully hit something along the way
				if(HitActor == None)
				{
					HitActor = Trace(HitLocation, HitNormal, Location, endp, true);
					if(HitActor == None)
						HitLocation = Location;
					bRecalcRadius=true;
				}
			}

			if(bRecalcRadius)
			{
				MeasureV = HitLocation - Location;
				MeasureV.z = 0;
				// Calc new radius size based on ground below you
				UseRadius = VSize(MeasureV);
				if(UseRadius <= MIN_RAD)
					UseRadius = MIN_RAD;
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Only made after we've checked some edges to hopefully not make a stupid
	// looking floating puddle, or one that goes through walls
	///////////////////////////////////////////////////////////////////////////////
	function MakeOurPuddle()
	{
		local FirePuddle fp;

		// recalculate our growing velocity
		RadVel = UseRadius/GrowTime;
		// Make our fire puddle now
		fp = FirePuddle(SpawnPuddle());
		fp.SetupLifetime(FirePuddleTime);
		fp.PrepExpansion(UseRadius, 40, Location, RadVel);
	}

Begin:
	// pos x
	CheckPoint = Location;
	CheckPoint.x += UseRadius;
	CheckGround(CheckPoint);
	Sleep(CheckTime);
	// neg x
	CheckPoint = Location;
	CheckPoint.x -= UseRadius;
	CheckGround(CheckPoint);
	Sleep(CheckTime);
	// pos y
	CheckPoint = Location;
	CheckPoint.y += UseRadius;
	CheckGround(CheckPoint);
	Sleep(CheckTime);
	// neg y
	CheckPoint = Location;
	CheckPoint.y -= UseRadius;
	CheckGround(CheckPoint);
	Sleep(CheckTime);

	MakeOurPuddle();
}

defaultproperties
{
	CheckTime = 0.05
	FirePuddleTime=5
	LifeSpan = 3.7		// wait time = 3.0 + growtime=0.7
	GrowTime=0.7		// lifetime without wait
	UseRadius=200		// used in radVel
	SpawnClass = class'FirePuddle'
	GasSource = None
}

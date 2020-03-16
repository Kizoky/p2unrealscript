//=============================================================================
// A series of AnthTrails
//=============================================================================
class AnthTrailList extends Anth;

var vector LastTrailLocation;
var int trailcount;
var AnthTrailPoint atrails[8];	// this number must be the same as MAX_TRAILS
const MAX_TRAILS=8;			// this number must be the same as the one above

const TRAIL_MAKE_TIME = 0.6;
const COLLISION_FREQ_TIME=2.0;

auto state Making
{
	function Tick(float DeltaTime)
	{
		atrails[trailcount-1].SetLineEnd(Location);
	}

	// Used to make a new trail
	function Timer()
	{
		local vector OldLoc;
		local vector HitNormal;

		if(trailcount < MAX_TRAILS)
		{
			atrails[trailcount] = spawn(class'AnthTrailMidPoint',,,Location);
			HitNormal = vect(0, 0, 1);
			atrails[trailcount].FindRightDir(HitNormal, Normal(Location - LastTrailLocation));
			// must be an absolute location;
			atrails[trailcount].SetLine(LastTrailLocation, Location);
			LastTrailLocation = Location;
			// Link them forward.
			//log("making this one "$atrails[trailcount]);
			if(trailcount > 0)
			{
				// tc-1 is the previous one, tc is the current one
				atrails[trailcount-1].Next = atrails[trailcount];
				//log("linked to by"$atrails[trailcount-1]);
			}
			// check if we're done
			trailcount++;
			if(trailcount >= MAX_TRAILS-1)
			{
				// Cap trail with an endpoint
				atrails[trailcount] = spawn(class'AnthTrailEndPoint',,,Location);
				//log("made trail end point "$atrails[trailcount]);
				HitNormal = vect(0, 0, 1);
				atrails[trailcount].FindRightDir(HitNormal, Normal(Location - LastTrailLocation));
				// link the one behind this to me
				if(trailcount > 0)
					atrails[trailcount-1].Next = atrails[trailcount];
				GotoState('Colliding');
			}
		}
	}

	function BeginState()
	{
		// Make trails at this time interval...
		SetTimer(TRAIL_MAKE_TIME, true);
		// Save where we are.
		LastTrailLocation = Location;
		// But make the starting one now.
		log("list begin");
		Timer();
	}
}

state Colliding
{
	function Timer()
	{
		//log("CALLING FIRST for collision "$Level.TimeSeconds);
		atrails[0].Timer();
	}
	
	function BeginState()
	{
		SetTimer(COLLISION_FREQ_TIME, true);
	}
}

defaultproperties
{
	LifeSpan=90.000000
	CollisionRadius=300
	CollisionHeight=300
}
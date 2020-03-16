//=============================================================================
// The end point for the trail. No visuals involved, only collision and physics
//=============================================================================
class AnthTrailEndPoint extends AnthTrailPoint;

function CheckToHitActors(float DeltaTime)
{
	// STUBBED OUT. No effect
}

function MoveCenters(float DeltaTime)
{
	local int i;
	// Move your center
	SetLocation(Location + Velocity*DeltaTime);
	CollisionLocation = Location;
	// Has not next, so don't look to update anything else
}

auto state Hurting
{
	function Tick(float DeltaTime)
	{
		// Doesn't perform any hurt checks

		// move center emitter to match particles
		CalcVel(DeltaTime);
		MoveCenters(DeltaTime);
	}
}

state WaitAndFade
{
	ignores Timer;

	// Don't hurt stuff here, in this state
	function BeginState()
	{
		AutoDestroy=true;
	}
}

// Perform collision operations
function Timer()
{
	local vector newhit, newnormal;
	local float dist;
	local vector NewAcc, OldAcc, checkv;
	local bool bhit;
	
	//log("collision called "$self);
	OldAcc=vect(0, 0, 0);

	colpt1 = Location;
	colpt2 = VEL_MAG_COL_MULT*Velocity + colpt1;
		
	// No Next to deal with here, so we're only checking ourselves. 
	if(Trace(newhit, newnormal, colpt2, colpt1, false) != None)
	{
		Velocity = (Velocity - 2 * newnormal * (Velocity Dot newnormal))/4;
		//NewAcc = Velocity;
//		NewAcc += (Velocity - 2 * newnormal * (Velocity Dot newnormal))/8;
//		Velocity/=2;
		//MainAcc += NewAcc;
		//Super.ApplyWindEffects(NewAcc, OldAcc);
		//log("END POINT new acc from hit: "$NewAcc);
	}

	// keep approx time of how long you've been doing this
	CollisionTime += COLLISION_MOVEMENT_FREQ_TIME;
	if(CollisionTime > HURTING_TIME)
		GotoState('WaitAndFade');
}

simulated event RenderOverlays( canvas Canvas )
{
/*	local color tempcolor;

	if(SHOW_LINES == 1)
	{
		tempcolor.G=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Circle(CollisionLocation, DamageDistMag, 0);
		tempcolor.R=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Line(colpt1, colpt2, 0);
	}
	*/
}

defaultproperties
{
}
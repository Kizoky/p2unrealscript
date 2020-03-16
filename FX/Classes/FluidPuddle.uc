//=============================================================================
// A standing puddle of fluid
//=============================================================================
class FluidPuddle extends Fluid;

var float RadMax;
// If the puddle is leaking, then it can no longer accept any quantity from
// a feeder, and begins to leak off from a certain point. It will not 
// diminish in size and will not stop leaking
var bool IsLeaking;
var FluidTrailStarter FStarter;
var FluidFlowTrail FFlowTrail;
var FluidDripFeeder FDrip;
var FluidFeeder FeederOwner;		// Feeder that I consider has started me
var FluidRippleEmitter Ripples;
var float CollisionAngle;
var class<FluidTrailStarter> TrailStarterClass;
var class<FluidDripFeeder> DripFeederClass;
var class<FluidRippleEmitter> RippleClass;

// BIG DEBUG stuff .. wastes memory
//var vector CheckSPt[4];
//var vector CheckEPt[4];

const MIN_KEEP_RADIUS = 50;
const MIN_SHAKE_CAMERA_RADIUS = 200;
const REMOVE_RADIUS_BUFFER	= 0;
const PUDDLE_HEIGHT=10;
const FUZZ=0.1;
const START_HEIGHT=10;
const END_HEIGHT=1000;
const DIST_TO_MAKE_STARTER=30;
const DEG_360 				= 6.28;
const CONVERT_360_TO_2PI 	= 0.01746;
const MAX_CHECKS=4;
const CHECK_ANGLE_CHANGE = 90; // must equal (360/MAX_CHECKS)
const MAIN_ANGLE_CHANGE = 10;
const PARENT_PUDDLE_RATIO=0.9;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	//SuperSpriteEmitter(Emitters[0]).LineStart = Location;
	//SuperSpriteEmitter(Emitters[0]).LineEnd = Location;
	Super.PostBeginPlay();

	// set radii
	Emitters[0].StartSizeRange.X.Min = UseColRadius;
	Emitters[0].StartSizeRange.X.Max = UseColRadius;
	Emitters[0].StartSizeRange.X.Min = UseColRadius;
	Emitters[0].StartSizeRange.Y.Max = UseColRadius;

	FindBestStartPos();

	if(RippleClass != None)
	{
		Ripples = spawn(RippleClass,self,,Location);
		Ripples.SetFluidType(MyType);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Only deletes the current batch of ripples
///////////////////////////////////////////////////////////////////////////////
function RemoveRipples()
{
	if(Ripples != None)
	{
		Ripples.Destroy();
		Ripples = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	RemoveRipples();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// handle ripples too
///////////////////////////////////////////////////////////////////////////////
function SetFluidType(FluidTypeEnum newtype)
{
	// set your type
	Super.SetFluidType(newtype);

	if(Ripples != None)
		Ripples.SetFluidType(MyType);
}

///////////////////////////////////////////////////////////////////////////////
// get us ready to fade
///////////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
	Super.ToggleFlow(TimeToStop, bIsOn);

	GotoState('WaitingToDie');
}

///////////////////////////////////////////////////////////////////////////////
// Look at the four walls around us and position ourselves between them best
///////////////////////////////////////////////////////////////////////////////
function FindBestStartPos()
{
	local FluidPuddle FPuddle;
	local vector NextPos, PrevPos, HitPos, HitNormal, StartPos;

	PrevPos = Location;
	// Check X pos
	NextPos = Location;
	NextPos.x+=UseColRadius;
	if(Trace(HitPos, HitNormal, NextPos, PrevPos, false) != None)
		StartPos = HitPos;
	else
		StartPos = NextPos;
	// Check X neg
	NextPos = Location;
	NextPos.x-=UseColRadius;
	if(Trace(HitPos, HitNormal, NextPos, PrevPos, false) != None)
		StartPos += HitPos;
	else
		StartPos += NextPos;
	// Check Y pos
	NextPos = Location;
	NextPos.y+=UseColRadius;
	if(Trace(HitPos, HitNormal, NextPos, PrevPos, false) != None)
		StartPos += HitPos;
	else
		StartPos += NextPos;
	// Check Y neg
	NextPos = Location;
	NextPos.y-=UseColRadius;
	if(Trace(HitPos, HitNormal, NextPos, PrevPos, false) != None)
		StartPos += HitPos;
	else
		StartPos += NextPos;

	// Put it at the average of these points (which are either
	// the true extent of the puddle, or a point within that
	//log(self$" start was "$Location);
	SetLocation(StartPos/4);
	//log(self$" start moved to "$Location);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
/*	//local vector endline;
	local color tempcolor;
	local int i;

	if(SHOW_LINES==1)
	{
		// show collision radius
		tempcolor.R=200;
		tempcolor.G=155;
		tempcolor.B=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Circle(Location, UseColRadius, 0);

		tempcolor.G=255;
		tempcolor.R=0;
		for(i=0; i<4; i++)
		{
			Canvas.DrawColor = tempcolor;
			Canvas.Draw3Line(CheckSPt[i], 
						 CheckEPt[i], 0);
		}
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TraceNearEdge(float RadiusAddition, vector StartPos, vector EndPos)
{
	local vector newhit, newnormal, dir;
	local float dist;
	local bool ForceDripMake;

	if(Trace(newhit, newnormal, EndPos, StartPos, false) == None)
	{
		IsLeaking=true;
		ForceDripMake = true;
		newhit = StartPos;
		newhit.z = Location.z;
		//log(self$"not hitting anything--no floor");
	}
	else
	{
		dist = Location.z - newhit.z;
		// Hit was above check location, so that means, it's hitting a 
		// solid wall that is above the puddle. So make the puddle
		// push away from this
		if(dist < -FUZZ)
		{
			//log(self$" hitting a wall and trying to move "$dist);
			dir = newhit - Location;
			dir.z=0;
			dir = Normal(dir);
			SetLocation(Location - RadiusAddition*dir);

		}
		// If within the fuzz, then it means it was hitting the same
		// surface, so don't pour off
		// But if dist is greater than fuzz (positive) then pour off
		// in a different manner
		else if(dist > FUZZ)
		{
			IsLeaking=true;
			// if too far away then make a drip for sure
			if(dist > DIST_TO_MAKE_STARTER)
			{
				//log(self$" making a drip "$dist);
				newhit.z = Location.z;
				ForceDripMake = true;
			}
			else
			{
				//log(self$" making a starter "$dist);
				//log(self$" hit at "$newhit$" loc at "$Location);
			}
		}
	}
	// If it's supposed to be leaking, then form a trail starter in that
	// spot.
	if(IsLeaking
		&& Next == None)
	{
		//log(self$"leaking check");
		// Check to make a starter or a drip feeder
		if(!ForceDripMake
			&& TrailStarterClass != None)
		{
			FStarter = spawn(TrailStarterClass, self,,newhit);
			FStarter.SetFluidType(MyType);
			FFlowTrail = FluidFlowTrail(FStarter.StartFirstTrail(newnormal, EndPos - StartPos));
		}
		// Try to make a drip feeder if the starter/flow trail pair from
		// above DIDN'T work.
		if(FFlowTrail == None)
		{
			// Since the flow trail didnt' get made, get rid of the starter too
			if(FStarter != None)
			{
				if(FStarter.bDeleteMe == false)
					FStarter.Destroy();
				FStarter = None;
			}
			// Try to make a drip feeder where the starter failed.
			dir = Normal(newhit - Location);
			//log(self$"new dir "$dir);
			FDrip = spawn(DripFeederClass,,,newhit);
			FDrip.SetFluidType(MyType);
			//log(self$"spawning drip feeder at "$newhit);
			//log(self$"puddle center "$Location);
			// move it a distance away from the ledge and down some
			FDrip.SetLocation(FDrip.Location + 5*dir);
			//log(self$"new drip loc "$FDrip.Location);
			FDrip.InitFlow();
			FDrip.SetDir(FDrip.Location + 5*dir, dir, 15);
			// link up feeder to puddle
			FDrip.Prev = self;
			Next = FDrip;
		}
		else // flow/starter will flow down the side now
		{
			//SpriteEmitter(FStarter.Emitters[0]).ProjectionNormal = newnormal;
			// link to flow trail
			FFlowTrail.Prev = self;
			Next = FFlowTrail;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function UpdateCollisionFromNewQuantity(float MoreQ, vector InputPoint, Fluid InputFluid)
{
	local vector StartPos, EndPos;
	local float CheckRad, RadiusAddition, useangle;
	local FluidFeeder InputFeeder;
	local int i;

	InputFeeder = FluidFeeder(InputFluid);

	if(RippleClass != None
		&& InputFeeder != None
		&& InputFeeder.bAllowPuddleRipples
		&& (Ripples == None
			|| Ripples.GetStateName() == 'FinishingUp'))
	{
		// reinit the ripples because the old ones are bogus
		Ripples = spawn(RippleClass,self,,Location);
		Ripples.SetFluidType(MyType);
	}

	// now move them to a good spot
	if(Ripples != None)
		Ripples.Reposition(InputPoint, Location, UseColRadius);

	// If just dripping in it and already full, so leave now--no reason to add more
	if(UseColRadius >= RadMax)
		return;

	// If were not leaking, accept more liquid, otherwise, skip
	if(!IsLeaking)
	{
		//Quantity+=MoreQ;
		RadiusAddition=(MoreQ*((RadMax-UseColRadius)/RadMax+0.2));
		UseColRadius+=RadiusAddition;
		if(UseColRadius > RadMax)
			UseColRadius = RadMax;
		// Increase the collision radius
		SetCollisionSize(UseColRadius, CollisionHeight);

		// Collision edge checks
		// Check around radius for collisions or ledges
		useangle = CollisionAngle;
		CheckRad = UseColRadius;
		StartPos.z = Location.z + START_HEIGHT;
		EndPos.z = Location.z - END_HEIGHT;
		i=0;
		while(i<MAX_CHECKS && !IsLeaking)
		{
			StartPos.x = Location.x + CheckRad*Cos(useangle);
			StartPos.y = Location.y + CheckRad*Sin(useangle);
			EndPos.x = StartPos.x;
			EndPos.y = StartPos.y;
			//CheckSPt[i] = StartPos;
			//CheckEPt[i] = EndPos;
			// Either creates a drip or a starter, or checks to
			// move the puddle from a wall. IsLeaking can
			// be in the following function, and these checks will
			// stop once that has happened.
			TraceNearEdge(RadiusAddition, StartPos, EndPos);
			useangle += (CHECK_ANGLE_CHANGE*CONVERT_360_TO_2PI);
			i++;
		}

		CollisionAngle += MAIN_ANGLE_CHANGE*CONVERT_360_TO_2PI;
		if(CollisionAngle>=DEG_360)
			CollisionAngle-=DEG_360;

		GotoState('WaitingToDie');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function AddQuantity(float MoreQ, vector InputPoint, Fluid InputFluid)
{
	UpdateCollisionFromNewQuantity(MoreQ, InputPoint, InputFluid);

	// If were not leaking, accept more liquid, otherwise, skip
	if(!IsLeaking)
	{
		// adjust visuals
		Emitters[0].StartSizeRange.X.Min = UseColRadius;
		Emitters[0].StartSizeRange.X.Max = UseColRadius+1;
		Emitters[0].StartSizeRange.Y.Min = UseColRadius;
		Emitters[0].StartSizeRange.Y.Max = UseColRadius+1;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool CheckToDissolve(optional Fluid RemoveF)
{
	local Fluid checkf;
	local Fluid keeppud, removepud;
	local FluidTrail ft;
	local bool bHitRemoved;
	local float RemoveRad;

	RemoveRad = UseColRadius;
	if(RemoveRad < MIN_KEEP_RADIUS)
		RemoveRad = MIN_KEEP_RADIUS;
	RemoveRad += REMOVE_RADIUS_BUFFER;
	// Specialty check to 'dissolve' any gas trails within the bounds of this puddle
	foreach RadiusActors(class'Fluid', checkf, RemoveRad)
	{
		if(checkf.MyType == MyType)
		{
			ft = FluidTrail(checkf);
			// if it's a trail, make sure both tips are inside this puddle before you 
			// wipe it out
			if(ft != None
				&& VSize(ft.Location - Location) < RemoveRad
				&& VSize(ft.LastEndPoint - Location) < RemoveRad)
			{
				//log(self$"removing "$checkf);
				checkf.SlowlyDestroy();
				if(RemoveF == checkf)
					bHitRemoved=true;
			}
			else if(FluidPuddle(checkf) != None)
			{
				if(checkf != self)
				{
					// Do a simple distance check between the two with
					// the distance between their radii and dissolve
					// the other into this one if it contains it completely
					if(UseColRadius > checkf.UseColRadius)
					{
						keeppud = self;
						removepud = checkf;
					}
					else
					{
						keeppud = checkf;
						removepud = self;
					}
					if(VSize(removepud.Location - keeppud.Location) 
						< keeppud.UseColRadius - removepud.UseColRadius + REMOVE_RADIUS_BUFFER)
					{
						removepud.SlowlyDestroy();
						if(RemoveF == checkf)
							bHitRemoved=true;
					}
				}
			}
		}
	}
	return bHitRemoved;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool CheckForKeepRadius()
{
	if(UseColRadius < MIN_KEEP_RADIUS
		&& !IsLeaking)
	{
		SlowlyDestroy();
		return false;
	}
	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool CheckToKeep()
{
	local bool keep;

	keep = CheckForKeepRadius();
	if(keep)
		CheckToDissolve();

	return keep;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetAblaze(vector StartPos, bool NewStart)
{
	local FirePuddle fp;
	local FireStarterRing fr;
	local FireWoof fw;
	local vector v1;
	local float newdist;
	local float TimeToGrow;

	//log("TRYING to set on fire "$self);
	//log("SETABLAZE "$self);
	// Make sure you're not already on fire.
	if(!bOnFire
		&& bCanBeDamaged)
	{
		bOnFire = true;
		// Make the start pos z component match the 
		// puddle's location z. 
		StartPos.z = Location.z;
		v1 = Location - StartPos;
		newdist = VSize(v1);
		v1 = Normal(v1);
		fr = spawn(class'FireStarterRing',,,StartPos);
		fr.Instigator = Instigator;
		// Try to make the type it takes to grow based on the size of the
		// puddle, so the smaller the puddle, the faster it grows.
		TimeToGrow = 2*UseColRadius/RadMax;
		if(TimeToGrow < 0.3)
			TimeToGrow = 0.3;
		fr.SetLifeSpan(TimeToGrow);
		//log("time for fire ring "$fr.LifeSpan);
		fr.Velocity = (newdist/TimeToGrow)*v1;
		//log(self$"this fire ring made "$fr$" use col "$UseColRadius$" max "$radmax$" new dist "$newdist$" time to grow "$TimeToGrow);
		//log(self$"vel for fire ring "$fr.Velocity);
		fr.RadVel = UseColRadius/TimeToGrow;
		//log("radvel for fire ring "$fr.RadVel);
		//log("Target radius for fire puddle "$UseColRadius);
		//log("ring rad vel "$fr.RadVel);
		fr.SpawnClass = Class'FirePuddle';
		fr.GasSource = self;
		// reset my own radius.
		fr.Emitters[0].StartLocationRange.X.Max=0;

		fp = FirePuddle(fr.SpawnPuddle());//spawn(class 'FirePuddle',,,Location);
		//log("made this fire puddle "$fp);
		fp.PrepExpansion(UseColRadius, MIN_KEEP_RADIUS, Location, fr.RadVel);
		fp.Velocity = fr.Velocity;

		fp.Emitters[0].StartLocationRange.X.Max = 0;

		// Move it in the ground a little,so it has to come out (looks better)
		v1 = Location;// - vect(0, 0, 40);
		fw = spawn(class'FireWoof',,,v1);
		fw.SetSize(UseColRadius);
		//if(UseColRadius > MIN_SHAKE_CAMERA_RADIUS)
		fw.ShakeCamera(UseColRadius/2);

		//log(self$" prev was "$Prev);
		//log(self$" next was "$Next);
		// Check to light the thing that fed you, right now
		if(Prev != None)
		{
			Prev.SetAblaze(Location, false);
		}
		// Check to light the thing that fed you, right now
		if(Next != None)
		{
			Next.SetAblaze(Location, false);
		}

		// Tell everyone along the way, we're about to be lit
		if(!bBeingLit)
			MarkBeingLit();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Waiting to die
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitingToDie
{
	// stub, doesnt' do anything normally
}

defaultproperties
{
   CollisionRadius=600.000000
   CollisionHeight=200.000000
	Health=100
   UseColRadius=20;
   RadMax = 375;
   TrailStarterClass = Class'FluidTrailStarter'
   DripFeederClass = Class'FluidDripFeeder'
   RippleClass = Class'FluidRippleEmitter'
}
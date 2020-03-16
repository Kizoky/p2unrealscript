///////////////////////////////////////////////////////////////////////////////
// FluidTrailStarter
// This is a fluid extension but has no visual representation. That is taken
// care of by the fluidflowtrial. Those particles expand quickly at first, 
// then very slowly. 
///////////////////////////////////////////////////////////////////////////////
class FluidTrailStarter extends Fluid;

// exported variables
var ()class<Fluid>	SpawnClass;
var ()class<FluidPuddle> PuddleClass;
var FluidFlowTrail FFlowTrail;

// internal variables
var Fluid SpawnedFluid;
var vector OldHitNormal;
var vector Acc; // acceleration
var vector OldLocation;
var vector OldVel;
var int Stopped;
var bool bDestroyStarter;
// Volume gravity is how much pull down is there, which determines how
// quickly the starter moves along the ground. A zeroed vector would
// cause the starter to slow to a stop and delete shortly.
var vector VolumeGravityVector;
var vector DampenVelocity;
var vector MaxVelocity;
var class<FluidDripFeeder> DripFeederClass;
var FluidDripFeeder FDripFeeder;
var FluidFeeder FeederOwner;
var bool bSevered;

// consts
const WAIT_TIME = 1;
const MIN_VELOCITY = vect(10, 10, 10);//30);
const DIFFERENT_NORMAL_DOT_MIN = 0.9;
const PUDDLE_NORMAL_Z_MIN = 1.0;
const FLAT_ENOUGH_NORMAL_Z = 0.95;
const VELOCITY_DOT_MIN = 0.8;
const DOWN_Z_CHECK_DIST = 200;
const CHECK_FOR_FLOOR	=	5000;
const MAX_TRAIL_DISTANCE = 1200;
const MAX_ONE_CYCLE_DISTANCE=100;//25
const MAKE_FEEDER_Z_DIST=60;
const PUSH_FROM_SURFACE=5;
const MIN_DIST_FOR_DRIP_FEEDER	=	60;
const FEEDER_VEL_RATIO = 0.3;
const BOOST_MAG	= 30;
const JUMP_PROBABILITY	= 0.3;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
//	StartPos = Location;
//	SetTimer(LifeSpan - WAIT_TIME, false);
//	SetTimer(0.3, true);
	Super.PostBeginPlay();
	Acc.z = VolumeGravityVector.z;
	OldLocation = Location;

//	Velocity+=(vect(0, -200, 0));
//	OldVel+=(vect(0, -200, 0));
	// check down to determine what normal we're on
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	SeverLinks();

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Fluid StartFirstTrail(vector OldNormal, optional vector FeederVel)
{
	local vector HitPos, HitNormal, NextPos, PrevPos;
	local Fluid fspawn;

	if(FeederOwner != None)
		FeederVel = FEEDER_VEL_RATIO*FeederOwner.StarterCollisionVel;

	//log("start first trail location "$Location);
	//log("OldNormal "$OldNormal);

	NextPos = Location - DOWN_Z_CHECK_DIST*OldNormal;
	PrevPos = Location + UseColRadius*OldNormal;
	//log("next pos check "$NextPos);
	if(Trace(HitPos, HitNormal, NextPos, Location, false) != None)
	{
		OldLocation = Location;
		//log("old loc "$OldLocation);
		SetLocation(HitPos + 5*HitNormal);
		//log("new loc "$Location);

		FitToSlope(HitNormal, true);
		// Set velocity to acceleration and the projection of the velocity from the feeder
		// on the plane of the collision. To get this, take the dot of the normal
		// and the velocity, then add this mag*Hitnormal to the velocity. This will eliminate
		// motion in the normal direction (pos or neg) and leave only motion along the plane
		// of collision
		//log("feeder vel "$FeederVel);
		Velocity += (abs(HitNormal dot FeederVel))*HitNormal;
		//log("vel on normal "$Velocity);
		Velocity = FeederVel + Velocity;
		//log("vel on plane "$Velocity);
		Velocity += Acc*0.1;
		OldVel=Velocity;
		return SpawnedFluid;
	}
	else
	{
		log(self$" no hit ");
		// kill me now!
		Destroy();
		return None;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function MovedByExcessQuantity(vector HitNormal)
{
	local vector addvel, forwardvec, rightvec;

	forwardvec = HitNormal;
	forwardvec.z = 0;
	rightvec = Normal(forwardvec) cross HitNormal;
	addvel = Normal(HitNormal cross Normal(rightvec));

	//log("boost vel dir "$addvel);
	
	addvel *= BOOST_MAG;
	//log("boost vel "$addvel);
	Velocity += addvel;
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	log(self$" severing links ");
	bDestroyStarter=true;
}
*/
///////////////////////////////////////////////////////////////////////////////
// stop all together
///////////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
//	Super.ToggleFlow(TimeToStop, bIsOn);
//	FFlowTrail.ToggleFlow(0, false);

//	log(self$" toggle flow, destroy starter ");
//	bDestroyStarter=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SeverLinks()
{
	if(!bSevered)
	{
		//log(self$" sever links, feeder owner "$FeederOwner$" flow trail "$FflowTrail);
		if(FFlowTrail != None)
		{
			if(FeederOwner == None
				|| FeederOwner.bStoppedFlow)
				FFlowTrail.ToggleFlow(0, false);
		}

		if(FeederOwner != None
			&& FeederOwner.FStarter == self)
		{
			FeederOwner.bStarterInvalid=true;
			FeederOwner.FStarter = None;
		}

		FeederOwner = None;
		FFlowTrail = None;
		SpawnedFluid = None;
		if(Next != None)
		{
			if(Next.Prev == self)
				Next.Prev=None;
			Next = None;
		}
		if(Prev != None)
		{
			if(Prev.Next == self)
				Prev.Next = None;
			Prev = None;
		}
		bSevered = true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ApplyDampenClamp(out float vx, float cx, float max, float min,
							   out int MinCapped)
{
	if(vx > 0)
	{
		vx -= cx;
		if(vx < min)
		{
			vx=0;
			return;
		}
		else if(vx > max)
			vx = max;
	}
	else
	{
		vx += cx;
		if(vx > -min)
		{
			vx=0;
			return;
		}
		else if(vx < -max)
			vx = -max;
	}
	MinCapped=0;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Fluid FitToSlope(vector HitNormal, bool bDoSpawn)
{
	local vector planecross, downvect;

	// Make a new one
	OldHitNormal = HitNormal;
	// Calculate a new acceleration to match
	// the new normal we're on
	planecross = HitNormal cross Normal(VolumeGravityVector);
	downvect = HitNormal cross Normal(planecross);
	//Velocity = VSize(Velocity)*downvect;
	OldVel = Normal(Velocity);
	Acc = (VolumeGravityVector dot downvect)*downvect;
	if(bDoSpawn)
		return SpawnStreak();
	else
		return None;
}

///////////////////////////////////////////////////////////////////////////////
// Randomly move a little left and right through imperfections in the surface
// you're moving along
// Assume velocity is greater than 0 in magnitude
///////////////////////////////////////////////////////////////////////////////
function JumpAroundOnSurface(vector HitNormal)
{
	local vector jumpvec;
	local float raduse, radhalf;
	
	if(FRand() < JUMP_PROBABILITY)
	{
		raduse = FFlowTrail.Emitters[0].StartSizeRange.X.Max;
		radhalf = raduse/2;

		jumpvec = Normal(HitNormal cross Normal(Velocity));

		SetLocation(Location + ((FRand()*raduse) - radhalf)*jumpvec);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	local vector HitNormal, HitPos, PrevPos, NextPos, ForwardNormal, ForwardPos;
	local vector checkvel, UseLoc;
	local float dotcheck, dotmax, dist, ZDist;
	local bool bMakeFeeder, bForwardHit;
	local int temp;
	local Actor HitActor;

	if(FFlowTrail == None
		|| FFLowTrail.bDeleteMe)
		SpawnStreak();

	Stopped=1;
	// do some physics
	checkvel = DampenVelocity * DeltaTime;

	ApplyDampenClamp(Velocity.x, checkvel.x, MaxVelocity.x, MIN_VELOCITY.x, Stopped);
	ApplyDampenClamp(Velocity.y, checkvel.y, MaxVelocity.y, MIN_VELOCITY.y, Stopped);
	ApplyDampenClamp(Velocity.z, checkvel.z, MaxVelocity.z, MIN_VELOCITY.z, Stopped);//temp);

//	Velocity -= (0.2*Velocity)*DeltaTime;

	NextPos = Location - DOWN_Z_CHECK_DIST*OldHitNormal;
	PrevPos = Location + UseColRadius*OldHitNormal;
	HitActor = Trace(HitPos, HitNormal, NextPos, PrevPos, false);

	//if(Stopped == 0)
		Velocity += Acc*DeltaTime;

	if(HitActor != None)
	{
		NextPos = Location + CollisionRadius*Normal(Velocity);
		PrevPos = Location;
		
		// Check along the line you plan to move and check for a collision
		bForwardHit = (Trace(ForwardPos, ForwardNormal, NextPos, PrevPos, false) != None);

		// Check to make sure the thing we're now hitting isn't a movable object
		if(!HitActor.bStatic)
		{
			bDestroyStarter=true;
			//log(self$" non static hit "$HitActor);
		}
		// Check that it's moving fast enough
		else if(VSize(Velocity) < 10
			&& HitNormal.z >= FLAT_ENOUGH_NORMAL_Z)
		{
			//log(self$" killing starter for lack of speed");
			bDestroyStarter=true;
		}
		// Check now to see if the new surface you're on is a 
		// flat one, so at this point, just break and make a puddle
		else if(HitNormal.z >= PUDDLE_NORMAL_Z_MIN
			|| (bForwardHit && ForwardNormal.z >= PUDDLE_NORMAL_Z_MIN))
		{
			SpawnPuddle();
			return;
		}
		// If the emitter has run out of particles, then make a new streak
		else if(SpawnedFluid != None
				&& SuperSpriteEmitter(SpawnedFluid.Emitters[0]) != None
				&& SuperSpriteEmitter(SpawnedFluid.Emitters[0]).ActiveParticles == SuperSpriteEmitter(SpawnedFluid.Emitters[0]).MaxParticles)
		{
			//log(self$" out of particles for this "$ss);
			FitToSlope(HitNormal, true);
			//SpawnStreak(HitNormal);
		}
		else
		{

			//		dotcheck = VSize(Location - HitPos);
			//		log("trace hit "$OldHitNormal);
			PrevPos = Location;
			NextPos = HitPos + PUSH_FROM_SURFACE*HitNormal;

//			OldLocation = Location;
//			SetLocation(HitPos + 2*HitNormal);
//			SuperSpriteEmitter(Emitters[0]).SetProjectionNormal(HitNormal);

			// First check if the distance between this hit and the last
			// hit is too far. If so, break off
			dotcheck = VSize(NextPos - PrevPos);
			if(dotcheck > MAX_ONE_CYCLE_DISTANCE)
			{
				//log("moved too far, making feeder "$dotcheck);
				// Check distance below
				// If it's too far, then make a drip feeder.
				// If it's close, then just warp this starter down there, and 
				// make a new trail
				PrevPos = Location;
				NextPos = Location;
				NextPos.z -= MAKE_FEEDER_Z_DIST;
				if(Trace(HitPos, HitNormal, NextPos, PrevPos, false) != None)
				{
					//log(self$" down hit "$hitpos$" diff is "$Location.z - hitpos.z);
					// warp the starter down there
					OldLocation = Location;
					SetLocation(HitPos + PUSH_FROM_SURFACE*HitNormal);
					//log("too far down "$ss$" but our dot check is "$dotcheck);
					if(HitNormal.z < PUDDLE_NORMAL_Z_MIN)
						SpawnStreak();
					else
						SpawnPuddle();
				}
				else	// far enough to make a feeder drip down
				{
					//log(self$" killing becuase too far ");
					bDestroyStarter=true;
				}
			}
			else
			{
				OldLocation = Location;
				SetLocation(HitPos + PUSH_FROM_SURFACE*HitNormal);

				// Checking to see if the change between the last normal
				// it hit and this current normal are too different. Use
				// the dot between the two normals vs. a number made based
				// on the distance from here to the start of the last spawn.
		//		log("Location "$Location);
				dotcheck = HitNormal dot OldHitNormal;
				if(SpawnedFluid != None)
				{
					dist = VSize(FFlowTrail.LastEndPoint - Location);
					dotmax = (3*dist)/(4*MAX_TRAIL_DISTANCE) + 0.7;
				}
				else
					dotmax = DIFFERENT_NORMAL_DOT_MIN;
				if(dotcheck < dotmax)
				{
					// Difference between two normals is too great, so
					// make a new streak
					//log("dotcheck "$dotcheck$" below dotmax "$dotmax$" for this "$ss);
					FitToSlope(HitNormal, true);
				}
				else if(Stopped == 0)
				{
					dotcheck = OldVel dot Normal(Velocity);
					if(dotcheck < VELOCITY_DOT_MIN)
					{
						OldVel = Normal(Velocity);
						//log("DID ONE OF THESE");
						//log("dotcheck too low "$dotcheck$" for this "$ss);
						SpawnStreak();
					}
					else
						JumpAroundOnSurface(HitNormal);
					/*
					else
					{
						log("dotcheck "$dotcheck);
						log("fitting to slope "$Velocity);
						FitToSlope(HitNormal, false);
						log("fitting to slope2 "$Velocity);
					}
					*/
				}
				else if(HitNormal.z >= FLAT_ENOUGH_NORMAL_Z)
				// Has stopped moving on level ground so we delete it
				{
					//log(self$" somehow stopped is 0. "$Velocity);
					bDestroyStarter=true;
				}
			}// within range for a single frame movement
		}// still have particles to make
	}
	else
		bMakeFeeder=true;

	if(bMakeFeeder)
	{
//		if(!bStoppedFlow)
//		{
			UseLoc = OldLocation + 5*Normal(Velocity);
			// Find how far it is to the floor (where we'll be hitting, about)
			PrevPos = UseLoc;
			NextPos = UseLoc;
			NextPos.z-=CHECK_FOR_FLOOR;
			if(Trace(HitPos, HitNormal, NextPos, PrevPos, false) != None)
				ZDist = PrevPos.z - HitPos.z;
			else
				ZDist = CHECK_FOR_FLOOR;

			//log(self$" zdist "$ZDist$" min dist "$MIN_DIST_FOR_DRIP_FEEDER$" flow "$FFlowTrail);
			//log(self$" hitnormal "$HitNormal$" first puddle "$(HitNormal.z >= PUDDLE_NORMAL_Z_MIN)$" sec pud "$(bForwardHit && ForwardNormal.z >= PUDDLE_NORMAL_Z_MIN));

			if(ZDist > MIN_DIST_FOR_DRIP_FEEDER
				&& FDripFeeder == None
				&& FFlowTrail != None)
			{
				FDripFeeder = spawn(DripFeederClass,,,UseLoc);
				FDripFeeder.SetFluidType(MyType);
				// hook the previous trail to this new feeder
				//log(self$" making drip ");
				//log(self$" fflowtrail next "$FFlowTrail.Next$" fprev "$FFlowTrail.Prev);
				// If it was already hooked to a spawned streak, then hook that streak to 
				// the new spawn
				FFlowTrail.Next = FDripFeeder;
				// Hook the new spawn back to the old one.
				FDripFeeder.Prev = FFlowTrail;
				// move it a distance away from the ledge and down some
				FDripFeeder.InitFlow();
				checkvel = Normal(Velocity);
				FDripFeeder.SetDir(FDripFeeder.Location, checkvel, VSize(Velocity)/8);
				FDripFeeder.SetQuantityBasedOnFloor(ZDist);
				//log(FFlowTrail$" AFTER drip fflowtrail next "$FFlowTrail.Next$" fprev "$FFlowTrail.Prev);
				//log(FDripFeeder$" AFTER drip FDripFeeder next "$FDripFeeder.Next$" fprev "$FDripFeeder.Prev);
				//log(self$"making feeder so kill starter");
				bDestroyStarter=true;
			}
			else if(HitNormal.z >= PUDDLE_NORMAL_Z_MIN
				|| (bForwardHit && ForwardNormal.z >= PUDDLE_NORMAL_Z_MIN))
				SpawnPuddle();
//		}
		// Get rid of this starter now
	}
//	else
//		Acc.z = VolumeGravityVector.z;

	if(bDestroyStarter)
	{
		//log(self$"Set to destroy");
		SeverLinks();
		Destroy();
		return;
	}

	if(Prev != None)
	{
		// drag the line emitter behind it
		FFlowTrail.UpdateLineEnd(Location);
		FFlowTrail.CheckToSpawnParticles(Location);
	}
	// check to stop the spawnclass if it hasn't been stopped yet
//	if(LifeSpan < WAIT_TIME && Emitters[0].AutoDestroy == false)
//		StopStarter();

	Super.Tick(DeltaTime);
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StopStarter()
{
	//log("stopping this emitter "$self);
	// stop the emitter from emitting
	AutoDestroy=True;
	//Emitters[0].AutoDestroy=True;
	//Emitters[0].RespawnDeadParticles=False;
	//Emitters[0].ParticlesPerSecond=0;

	// stop the motion
	Velocity=vect(0, 0, 0);
}
*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Fluid SpawnStreak()
{
	// Don't allow others to be made
	if(bStoppedFlow)
		return None;

	// Spawn the new streak
	SpawnedFluid = spawn(SpawnClass,,,Location);
	// Check to make sure it's correct, and then form links
	if(SpawnedFluid != None)
	{
		// Unhook old links
		if(Prev != None)
		{
			// If it was already hooked to a spawned streak, then hook that streak to 
			// the new spawn
			Prev.Next = SpawnedFluid;
			// Hook the new spawn back to the old one.
			SpawnedFluid.Prev = Prev;
		}
		// Link up
		Prev = SpawnedFluid;
		SpawnedFluid.Next = self;

		FFlowTrail = FluidFlowTrail(SpawnedFluid);
		FFlowTrail.SetProjectionNormal(OldHitNormal);
		if(FeederOwner != None)
		{
			FeederOwner.FFlowTrail = FFlowTrail;
			FFlowTrail.FeederOwner = FeederOwner;
		}
		FFlowTrail.SetFluidType(MyType);
		//log(self$" spawning a new streak "$SpawnedFluid$" next for spawned "$SpawnedFluid.Next);
	}

	return SpawnedFluid;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SpawnPuddle()
{
	local FluidPuddle FPuddle, HitPuddle, KeepPuddle;
	local Actor HitActor, CheckA;
	local vector NextPos, PrevPos, HitPos, HitNormal;
	local float dist, keepdist;

	// Don't allow others to be made
	if(bStoppedFlow)
		return;

	// Only make a puddle if we're flowing from something and we have
	// a feeder still giving us fluid
	if(FFlowTrail != None)
	{
		// First find a sure spot below us, to make the puddle
		PrevPos = Location;
		PrevPos.z+= UseColRadius;
		NextPos = Location;
		NextPos.z-=DOWN_Z_CHECK_DIST;
		HitActor = Trace(HitPos, HitNormal, NextPos, PrevPos, false);
		if(HitActor != None)
		{
			keepdist = MAX_PUDDLE_SIZE;

// do a radius actors test here

			foreach TraceActors( class 'Actor', CheckA, HitPos, HitNormal, NextPos, PrevPos )
			{
				//log("hit actor now "$CheckA);
				HitPuddle = FluidPuddle(CheckA);
				//log("hit actor "$HitPuddle);
				if(HitPuddle != None)
				{
					// make sure you're the same liquid type
					if(HitPuddle.MyType == MyType)
					{
						dist = VSize(HitPuddle.Location - HitPos);
						// find the closest puddle
						if(keepdist > dist)
						{
							//log("keeping "$HitPuddle);
							keepdist = dist;
							KeepPuddle = HitPuddle;
						}
					}
				}
			}
			if(PuddleClass != None)
			{
				//log(self$" final hit puddle "$KeepPuddle);
				if(KeepPuddle == None)
				{
					//log(self$" making puddle on flat surface at "$HitPos);
					// Make a puddle now at the base and kill yourself
					FPuddle = spawn(PuddleClass,,,HitPos);
					FPuddle.SetFluidType(MyType);
					FPuddle.Prev = FFlowTrail;
					// We never make puddles with ripples--we don't move fast enough
					FPuddle.RemoveRipples();
					FPuddle.GotoState('WaitingToDie');
					// Unconnect to a drip feeder if we have one
					if(FDripFeeder != None)
					{
						//log(self$" toggle flow 3");
						FDripFeeder.ToggleFlow(0, false);
					}
					// Connect this puddle to the flow trail, so it can fill it
					FFlowTrail.FPuddle = FPuddle;
					FFlowTrail.Next = FPuddle;
				}
			}
		}
	}

	//log(self$"killing in spawn after spawnpuddle check");
	SeverLinks();
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
	local color tempcolor;
	local vector usevect, usevect2;

	tempcolor.G=255;
	Canvas.DrawColor = tempcolor;

	usevect = Location;
	usevect.z+=CollisionRadius;
	usevect2 = Location;
	usevect2.z-=CollisionRadius;
	Canvas.Draw3DLine(usevect, usevect2);

	usevect = Location;
	usevect.x+=CollisionRadius;
	usevect2 = Location;
	usevect2.x-=CollisionRadius;
	Canvas.Draw3DLine(usevect, usevect2);
}

defaultproperties
{
     SpawnClass=Class'Fx.FluidFlowTrail'
     PuddleClass=Class'Fx.FluidPuddle'
     Physics=PHYS_Projectile
     LifeSpan=0.000000
     CollisionRadius=5.000000
     CollisionHeight=5.000000
	 UseColRadius=30
	 VolumeGravityVector=(Z=-800)
	 DampenVelocity=(X=250.000000,Y=250.000000,Z=250.000000)
	 MaxVelocity=(X=200.000000,Y=200.000000,Z=200.000000)
	 DripFeederClass = Class'FluidDripFeeder'
}

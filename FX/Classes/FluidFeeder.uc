///////////////////////////////////////////////////////////////////////////////
// Fluid fall from a source
///////////////////////////////////////////////////////////////////////////////
class FluidFeeder extends Fluid;

var float EmitTime;
var FluidSplashEmitter FSplash;
var FluidTrail FTrail;
var FluidTrailStarter FStarter;
var FluidFlowTrail FFlowTrail;
var FluidPuddle FPuddle;
var FireStarterFollow MyFire;
var vector NewSpawnPoint;
var vector CollisionStart;			// Location where we start doing collision--can differ from *visual* emitter
var bool bFlowing;
var bool bCanHitActors;				// If this stream of fluid collides with actors
var int  TryToMake;
var float SpawnDripTime;
var float QuantityPerHit;
var float MomentumTransfer;
var class<FluidSplashEmitter> SplashClass;
var class<FluidTrail> TrailClass;
var class<FluidTrailStarter> TrailStarterClass;
var class<FluidPuddle> PuddleClass;
var bool bAllowPuddleRipples;	// Major feeders allow this, smaller ones don't
var class<FireStarterFollow> StarterClass;
var float TimeToMakePuddle;		// used to determine how long the feeder must hit the same spot before this is made
var float TimeToMakeStarter;	// used to determine how long the feeder must hit the same spot before this is made
var class<DamageType> MyDamageType;	// Damage we might incur on a hit by a feeder
var float StartingTime;			// How long it waits to start pouring
var bool bFullyActive;			// It's been flowing for long enough (in Pouring state) to do something important.
var bool bStarterInvalid;		// If true, then we're in a spot on a slope where the starter was spawned,
								// but it's gone and we're still pouring on that spot--if we move or stop--this will be reset.

// fake arc
var vector LastHitPos, LastHitNormal;
var int ArcIndexHit;
var vector StarterCollisionVel;	// Velocity that arc had when it hit surface and said to make a starter
var vector LastHitLocation;	// Last place it hit (updated every trace)

const MAX_FLOAT	=	32000;
const FLIP_TIME=4;
const EXTEND_STREAM_MIN_DOT = 0.97;
const DIFFERENT_NORMAL_MIN_DOT = 0.9;
const FLAT_GROUND_Z	=	1.0;
const ALMOST_FLAT_Z	=	0.9;
const NORMAL_DIST_MOVE	=	10;
const MAX_TRAIL_DISTANCE = 1600;
const MAX_ONE_CYCLE_DISTANCE = 200;
const MIN_Z_NORMAL_FOR_STARTER = 0.1;
const MAX_PLAYER_SPEED = 600;
const MAKE_STARTER = 1;
const MAKE_PUDDLE = 2;
const HIT_LOCATION_FUZZ	=	0.1;
const FTRAIL_UPDATE_RADIUS	= 2.0;
const FULLY_ACTIVE_TIME	= 1.5;

const EXPLODE_DAMAGE = 1;
const EXPLODE_RADIUS = 500;

const VECTOR_RATIO	=	100;	// Maintain precision in MP replication

replication 
{
	// Server sends this to client
	reliable if(Role == ROLE_Authority)
		ClientSetDir;
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.2, true);
	NewSpawnPoint = Location;
	CollisionStart = Location;
	LastHitPos = Location;
	FTrail=None;
	Prev=None;
	Next=FTrail;
	InitFlow();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function InitFlow()
{
	if(FSplash == None
		&& SplashClass != None)
	{
		FSplash = spawn(SplashClass, self);
		FSplash.SetFluidType(MyType);
		FSplash.EnableSpawnAll(false);
		SetFluidType(MyType);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle splash too
///////////////////////////////////////////////////////////////////////////////
function SetFluidType(FluidTypeEnum newtype)
{
	// set your type
	Super.SetFluidType(newtype);

	if(FSplash != None)
		FSplash.SetFluidType(MyType);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SeverTrail(float TimeToStop, bool bIsOn)
{
	if(FTrail != None)
	{
		FTrail.ToggleFlow(TimeToStop, bIsOn);
		FTrail = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SeverStarter(float TimeToStop, bool bIsOn)
{
	if(FStarter != None)
	{
		FStarter.bDestroyStarter=true;
		FStarter = None;
	}
	if(FFlowTrail != None)
	{
		FFlowTrail.ToggleFlow(TimeToStop, bIsOn);
		FFlowTrail = None;
	}
	// Clear the invalid starter flag at the very end. It can only be invalid if 
	// the starter kills itself and we don't know about it. Since we're
	// instigating the destroy, we know it's fine.
	bStarterInvalid=false;
}

///////////////////////////////////////////////////////////////////////////////
// Stub for setting the direction
///////////////////////////////////////////////////////////////////////////////
function SetDir(vector newloc, vector startdir, optional float velmag, optional bool bInitArc)
{
}

///////////////////////////////////////////////////////////////////////////////
// Stub for setting the direction
///////////////////////////////////////////////////////////////////////////////
function ServerSetDir(vector newloc, vector startdir, optional float velmag, optional bool bInitArc)
{
}

///////////////////////////////////////////////////////////////////////////
// Make the emitter shoot out of Rotation
///////////////////////////////////////////////////////////////////////////
simulated function ClientSetDir(vector newpos, vector newloc, vector startdir, optional float velmag)
{
}
 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool SeverPuddle(out FluidPuddle CheckP, float TimeToStop, bool bIsOn)
{
	local bool bKeep;

	if(CheckP != None)
		CheckP.ToggleFlow(TimeToStop, bIsOn);

	//log("nulling this puddle "$CheckP);
	bKeep = false;
	if(CheckP != None)
	{
		bKeep = CheckP.CheckToKeep();
		CheckP = None;
	}

	return bKeep;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SeverLinks(float TimeToStop, bool bIsOn)
{
	SeverStarter(TimeToStop, bIsOn);
	SeverTrail(TimeToStop, bIsOn);
	SeverPuddle(FPuddle, TimeToStop, bIsOn);
	if(FSplash != None)
		FSplash.EnableSpawnAll(false);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	SeverLinks(0, false);
	if(FSplash != None)
	{
		FSplash.Destroy();
		FSplash = None;
	}
	if (FTrail != None && FTrail.Feeder == Self)
		FTrail.Feeder = None;
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
	bFlowing=bIsOn;

	if(FSplash != None)
		FSplash.EnableSpawnAll(false);
	if(MyFire != None)
		MyFire.StopStarter(false);

	bStoppedFlow=!bIsOn;

	// record if it's ever stopped at all
	if(bStoppedFlow)
		bStoppedOnce = true;

	SeverLinks(TimeToStop, bIsOn);

	Super.ToggleFlow(TimeToStop, bIsOn);

	if(!IsInState('Dying'))
		GotoState('Dying');
}

///////////////////////////////////////////////////////////////////////////////
// Convert hue, saturation, and brightness to an red-green-blue color format
///////////////////////////////////////////////////////////////////////////////
function GetHSV(byte h, byte s, byte v, out vector hue)
{
	local FLOAT Brightness;
	Brightness = V * 1.4f / 255.f;
	Brightness *= 0.7f/(0.01f + sqrt(Brightness));
	Brightness  = Clamp(Brightness,0.f,1.f);
	if(h < 86)
	{
		hue.x = (255*(85-h))/85;
		hue.y = (255*(h-0))/85;
		hue.z = 0;
//		hue = vector((85-H)/85,(H-0)/85,0);
	}
	else if( h < 171)
	{
		hue.x = 0;
		hue.y = (255*(170-h))/85;
		hue.z = (255*(h-85))/85;
//		hue = vector(0,(170-H)/85,(H-85)/85);
	}
	else
	{
		hue.x = (255*(h-170))/85;
		hue.y = 0;
		hue.z = (255*(255-h))/84;
//		hue = vector((H-170)/85,0,(255-H)/84);
	}
//	hue = (H<86) ? FVector((85-H)/85.f,(H-0)/85.f,0) : (H<171) ? FVector(0,(170-H)/85.f,(H-85)/85.f) : FVector((H-170)/85.f,0,(255-H)/84.f);
}
/*
///////////////////////////////////////////////////////////////////////////////
// Change the lighting for the emitter based on the nearest light
///////////////////////////////////////////////////////////////////////////////
function AdjustLighting()
{
	local int i;
	local Light thislight;
	local Light pickedlight;
	local float pickedmag, checkmag;
	local vector c;

	//log("attempt lighting change");
	// pick a far distance
	pickedmag = MAX_FLOAT;

	foreach AllActors(class 'Light', thislight)
	{
//		if(thislight.LightBrightness > mag)
//		{
//			mag=thislight.LightBrightness;
//			pickedlight = thislight;
//		}
		checkmag = VSize(Location - thislight.Location);
		if(checkmag < pickedmag)
		{
			pickedmag = checkmag;
			pickedlight = thislight;
		}
	}
	// we found one
	if(pickedmag != MAX_FLOAT)
	{
//		log("found light");
//		log("hue: "$pickedlight.LightHue);
//		log("sat: "$pickedlight.LightSaturation);
//		log("bri: "$pickedlight.LightBrightness);
		GetHSV(pickedlight.LightHue, pickedlight.LightSaturation, pickedlight.LightBrightness, c);
//		log("new color "$c);
		for(i=0; i<Emitters.length; i++)
		{
		Emitters[i].ColorScale[1].Color.R = (c.x + Emitters[i].ColorScale[1].Color.R)/2;
		Emitters[i].ColorScale[1].Color.G = (c.y + Emitters[i].ColorScale[1].Color.G)/2;
		Emitters[i].ColorScale[1].Color.B = (c.z + Emitters[i].ColorScale[1].Color.B)/2;
//		Emitters[i].ColorScale[2].Color.R = (c.x + Emitters[i].ColorScale[2].Color.R)/2;
//		Emitters[i].ColorScale[2].Color.G = (c.y + Emitters[i].ColorScale[2].Color.G)/2;
//		Emitters[i].ColorScale[2].Color.B = (c.z + Emitters[i].ColorScale[2].Color.B)/2;
		}
	}
}
*/
 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	//AdjustLighting();
}

///////////////////////////////////////////////////////////////////////////////
// If the thing this feeder is coming from, is staying pretty still, then 
// consider it not moving.
///////////////////////////////////////////////////////////////////////////////
function bool NotMoving()
{
	if(Instigator != None)
	{
		return (VectorsInFuzz(Instigator.Velocity, vect(0, 0, 0), 0.1));		
	}
	else
	{
		Instigator = None;
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool VectorsInFuzz(vector v1, vector v2, float fuzz)
{
	return(v1.x > v2.x-fuzz && v1.x < v2.x+fuzz
		&& v1.y > v2.y-fuzz && v1.y < v2.y+fuzz
		&& v1.z > v2.z-fuzz && v1.z < v2.z+fuzz);

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ExtendTheStream(vector GroundHit, vector HitNormal)
{
	local FluidTrail newfuel;

	if(FTrail != None
		&& !FTrail.bPendingDelete
		&& TrailClass != None)
	{
		// Make a new one
		newfuel = spawn(TrailClass, MyOwner,,FTrail.LastEndPoint);
		if(newfuel != None)
		{
			// Link the old one to the new one (because they're touching)
			FTrail.Prev = newfuel;
			// Link the old one to the new one
			newfuel.Next = FTrail;
			// Link new trail to this feeder
			newfuel.Prev = self;
			// if the old one was a line type, then extend to that.
			newfuel.SetLineEnd(newfuel.Location, GroundHit);

			FTrail.UpdateLineEnd(GroundHit);
			FTrail.EndingFeederConnection();
			FTrail = newfuel;
			Next = FTrail;
			FTrail.SetProjectionNormal(HitNormal);
			FTrail.FitToNormal(HitNormal);
			if(Instigator != None)
					FTrail.CalcParticleNeed(VSize(Instigator.Velocity)/MAX_PLAYER_SPEED);
			FTrail.SetFluidType(MyType);
			FTrail.StartLineDirection = Normal(FTrail.LastEndPoint - FTrail.Location);
			FTrail.Feeder = Self;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// A starter is a fluid type that continues from the splash point and makes
// fluid trails down sloped surfaces (like fluid racing down a slope)
///////////////////////////////////////////////////////////////////////////////
function HandleStarter(vector GroundHit, vector HitNormal, vector HitVel, float DeltaTime)
{
	// Don't work with these, if there's a puddle
//	if(FPuddle != None)
//		return;

	//log(self$" fstarter "$fstarter$" delete "$fstarter.bdeleteme);
	if(HitNormal.z < FLAT_GROUND_Z)
	{
		if(!bStarterInvalid
			&& FStarter == None 
			&& TryToMake == 0)
		{
			NewSpawnPoint = GroundHit;
			//log(self$" setting NewSpawnPoint to the following: "$NewSpawnPoint);
		}
		// Within the same spot as before.
		if(NotMoving() && VSize(GroundHit - NewSpawnPoint) < UseColRadius)
		{
			// If this is false, make a new starter or handle the old one (if it's true
			// wait for the feeder to be moved so bStarterInvalid can be cleared)
			if(!bStarterInvalid)
			{
				// If we haven't already started a timer to possibly
				// begin a trail starter, then do so. 
				// The timer can be cancelled if the 'else' below gets hit.
				if(FStarter == None)
				{
					if(TryToMake == 0 && bFlowing == true)
					{
						//log(self$" set try for FStarter");
						TryToMake = MAKE_STARTER;
						StarterCollisionVel = HitVel;
						SetTimer(TimeToMakeStarter, false);
					}
				}
				// As expected, the feeder is pouring onto something while a fluid starter
				// races away from it. 
				else
				{
					// Check to see if the surface we're hitting is very shallow or steep
					if(HitNormal.z > ALMOST_FLAT_Z)
						FStarter.MovedByExcessQuantity(HitNormal);
				}
			}
		}
		// Hit point where the end of the feeder hits something, has moved
		else
		{
			//if(FStarter != None)
			//	log(self$" feeder moved, so fix starter "$FStarter$" delete "$FStarter.bDeleteMe);
			//log(self$" cancelling make of new one ");
			// Don't try to make the starter now, the flow has moved.
			if(TryToMake == MAKE_STARTER)
				TryToMake = 0;
			// Detach yourself from the FStarter and gflow
			SeverStarter(0, false);
			// Clear the invalid starter flag at the very end. We've moved, so we know the starter
			// will be valid after this. It can only be invalid if the starter kills itself and
			// we don't know about it.
			bStarterInvalid=false;
		}
	}
	else if(TryToMake == MAKE_STARTER)
	{
		bStarterInvalid=false;
		// if you were on an angled surface trying to make a starter, then stop it now
		TryToMake = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetupPuddleMake()
{
	TryToMake = MAKE_PUDDLE;
	SetTimer(TimeToMakePuddle, false);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function HandlePuddle(vector GroundHit, vector HitNormal, float DeltaTime)
{
	local vector dir;
	local vector v1, v2;
	local float savedist, vdist1, vdist2;
	local float u, dotcheck, dotmax, DistToNewPoint;
	local bool WithinArea;
	
	// Kamek add for log de-spam
	if (fPuddle == None || fPuddle.bDeleteMe)
		FPuddle = None;

	// We already have a puddle
	if(FPuddle != None)
	{
		if(!FPuddle.bDeleteMe)// stretch the one there, or break it and make a new one
		{
			DistToNewPoint = VSize(GroundHit - FPuddle.Location);

			// if its within the area of the puddle, then add more area to the puddle
			//log("fpuddle loc "$FPuddle.Location);
			//log("ground hit "$GroundHit);
			if(DistToNewPoint <= FPuddle.UseColRadius + PUDDLE_FUZZ
				&& (FPuddle.Location.z > (GroundHit.z -  FPuddle.PUDDLE_HEIGHT)
					&& FPuddle.Location.z < (GroundHit.z + FPuddle.PUDDLE_HEIGHT))
					&& HitNormal.z >= FLAT_GROUND_Z)
			{
				FPuddle.AddQuantity(QuantityPerHit*DeltaTime, GroundHit, self);
			}
			// else if it's outside of the puddle, then break the connection to it
			else
			{
				//log("fpuddle to none");
				// Check to start up the trail again, now that we've left that
				// puddle
				if(SeverPuddle(FPuddle, 0, false) == true)
				{
					// If youre keeping the puddle, then break your tie with the old trail you 
					// had going and make it start a new one
					SeverTrail(0, false);
				}
				FPuddle = None;
			}
		}
	}
	// Check the making of a new one
	else if(HitNormal.z >= FLAT_GROUND_Z)
	{
		if(FPuddle == None && TryToMake == 0)
		{
			NewSpawnPoint = GroundHit;
		}

		WithinArea = (NotMoving() && VSize(GroundHit - NewSpawnPoint) < UseColRadius);

		if(TryToMake == 0)
		{
			NewSpawnPoint = GroundHit;
			//log("puddle setting NewSpawnPoint to the following: "$NewSpawnPoint);
			if(WithinArea)
			{
				// If we haven't already started a timer to possibly
				// begin a trail starter, then do so. 
				// The timer can be cancelled if the 'else' below gets hit.
				if(bFlowing == true)
				{
					//log("trying to make a new puddle");
					SetupPuddleMake();
				}
			}
		}
		else if(!WithinArea)
			// If you were told to make a puddle, but got moved, then cancel the 
			// order 
		{
			if(TryToMake == MAKE_PUDDLE)
				TryToMake = 0;
		}
	}
	else if(TryToMake == MAKE_PUDDLE)
	// if you were on a flat surface, trying to make a puddle, then stop it now
	{
		TryToMake = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function HandleTrail(vector GroundHit, vector HitNormal)
{
	local vector dir;
	local vector v1, v2;
	local float savedist, vdist1, vdist2, userad;
	local float u, dotcheck, dotmax, DistToNewPoint;
	local bool bExtendStream;
	local bool bSeverStream;
	
	// Don't work with these, if there's a puddle
	if(FPuddle != None)
		return;
	if(FTrail == None
		|| FTrail.bDeleteMe
		|| FTrail.bPendingDelete)
	{
		if(TrailClass != None)
		{
			FTrail = spawn(TrailClass, MyOwner,,GroundHit);
			if(FTrail != None)
			{
				//log(FTrail$" spawning a FTrail here "$GroundHit);
				// Link new trail to this feeder
				FTrail.Prev = self;
				// and link feeder to trail
				// (since we're yanking our old one's connection, unhook it
				// if it points to us)
				if(Next != None
					&& Next.Prev == self)
					Next.Prev = None;
				Next = FTrail;
				FTrail.FitToNormal(HitNormal);
				FTrail.SetProjectionNormal(HitNormal);
				if(Instigator != None)
					vdist1 = VSize(Instigator.Velocity)/MAX_PLAYER_SPEED;
				else
					vdist1 = 1.0;
				FTrail.CalcParticleNeed(vdist1);
				FTrail.SetFluidType(MyType);
				FTrail.StartLineDirection = Normal(Location - LastHitPos);
				FTrail.Feeder = Self;
			}
		}
	}	
	// stretch the one there, or break it and make a new one if you're not dealing with a puddle
	else
	{
		DistToNewPoint = VSize(GroundHit - FTrail.LastEndPoint);

		if(DistToNewPoint > MAX_ONE_CYCLE_DISTANCE)
		{
			//log("ground hit "$GroundHit);
			//log("line end "$SuperSpriteEmitter(FTrail.Emitters[0]).LineEnd);
			bSeverStream=true;
		}
		else //if(SuperSpriteEmitter(FTrail.Emitters[0]).LocationShapeExtend == PTLSE_Line)
		// If a line has been created, then lengthen the stream along the line
		{
			if(FTrail.ParticlesInactive() <= 0)
			{
				//log("EXTEND0 out of particles");
				bExtendStream = true;
			}
			else if(FTrail.Emitters.Length > 0)
			{
				dotcheck = SuperSpriteEmitter(FTrail.Emitters[0]).ProjectionNormal dot HitNormal;
				vdist1 = VSize(FTrail.LastEndPoint - FTrail.Location);
				dotmax = (3*vdist1)/(4*MAX_TRAIL_DISTANCE) + 0.75;

				if(dotcheck < dotmax)
				{
					bExtendStream = true;
					//log("EXTEND1 dotcheck < dotmax "$dotcheck$" hitnormal "$HitNormal$" dotmax "$dotmax$" vdist "$vdist1);
				}
	//			else
	//				SuperSpriteEmitter(FTrail.Emitters[0]).LineEnd = GroundHit;
				else
				{
					//vdist1 = VSize(SuperSpriteEmitter(FTrail.Emitters[0]).LineEnd - FTrail.Location);
					v1 = FTrail.StartLineDirection;
					v2 = GroundHit - FTrail.Location;
					vdist2 = VSize(v2);
					v2 = Normal(v2);
					//dotcheck =  v2 dot v1;
					dotcheck = v2 dot v1;
					//log(FTrail$" v1 "$v1$" v2 "$v2$" dot "$dotcheck$" cap "$EXTEND_STREAM_MIN_DOT);
					// If it's farther along the stream than the end of the stream already
					// is. (if not, then it's like adding to the middle of the stream),
					// so nothing happens right now.
					// The second check is to make sure that the full distance of the line emitter
					// has not extended the static cylinder collision radius for the puddle/stream
					// minus the small distance away from the line.

					//dotmax = (3*vdist1)/(4*MAX_TRAIL_DISTANCE) + 0.75;
					//if( dotcheck > dotmax )
					if(dotcheck > EXTEND_STREAM_MIN_DOT)
					{
						if(vdist2 > vdist1)
						{
							// If the new spot is past the end of the max for the stream, make a new
							// one right there. If not, then just extend this one, along its current
							// path.
							if(vdist2 < (FTrail.default.CollisionRadius - FTrail.default.UseColRadius))
							{
								//SuperSpriteEmitter(FTrail.Emitters[0]).LineStart = SuperSpriteEmitter(FTrail.Emitters[0]).LineEnd;
								//SuperSpriteEmitter(FTrail.Emitters[0]).LineEnd = GroundHit;
								FTrail.UpdateLineEnd(GroundHit);
							}
							else
							{
								//log("EXTEND2 : past end "$vdist2);
								bExtendStream=true;
							}
						}
					}
					else
					{
						
						// If an already extended stream, then check if you're within the 
						// default radius.. if so, then just update the position, if not,
						// it means you're outside the safe radius and your angle is outside
						// the range
						if(vdist2 < //FTRAIL_UPDATE_RADIUS)
								FTrail.default.UseColRadius)
						{
							//SuperSpriteEmitter(FTrail.Emitters[0]).LineStart = SuperSpriteEmitter(FTrail.Emitters[0]).LineEnd;
							//SuperSpriteEmitter(FTrail.Emitters[0]).LineEnd = GroundHit;
							FTrail.UpdateLineEnd(GroundHit);
						}
						else
						{
							//log("EXTEND3 outside usecolradius "$vdist2$" usecol "$FTrail.default.UseColRadius);
							bExtendStream = true;
						}
					}
				}// normals are in range
			} // you still have enough particles here
		}
		/*
		else // If not already a line type, then make it so, and extend the line to meet the new
			// hit point on the ground.
		{
			// Check to see if the next hit is outside of the collision radius for the trail.
			// If it is, then extend the trail to meet it.
			userad = 5;//(VSize(Instigator.Velocity)*FTrail.default.UseColRadius)/MAX_PLAYER_SPEED + FTrail.default.UseColRadius;
			if(VSize(GroundHit - FTrail.Location) > userad)
			{
				//log("use rad ");
				//log("ground hit "$groundhit);
				SuperSpriteEmitter(FTrail.Emitters[0]).LocationShapeExtend=PTLSE_Line;
				FTrail.SetLineEnd(GroundHit, GroundHit);
				//SuperSpriteEmitter(FTrail.Emitters[0]).LineEnd = GroundHit;
				FTrail.StartLineDirection = Normal(FTrail.LastEndPoint - FTrail.Location);
//				log("found my start line dir "$FTrail.StartLineDirection);
//				log("location : "$FTrail.location);
//				log("groundhit : "$groundhit);
			}
			else
				FTrail.UpdateLineEnd(GroundHit);
		}
		*/
		// If the angle from the last stream is too sharp, or it's moved to a
		// much differing normal, then make/extend the last stream to a new one
		if(bExtendStream)
		{
			//log("extend");
			ExtendTheStream(GroundHit, HitNormal);
		}
		// Has been stretched across too great an area, so cut it.
		if(bSeverStream)
		{
			//FTrail.SetLineEnd(GroundHit);
//			StripEmitter(FTrail.Emitters[0]).ForceSpawn(1, 1);
			SeverTrail(0, false);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CheckForFluidHit(vector StartLoc, vector EndLoc, 
						  vector HitVel, vector GroundHit, 
						 vector HitNormal, float DeltaTime)
{
	// raise the ground hit up some--that is, away from the normal
//	GroundHit += NORMAL_DIST_MOVE*HitNormal;

	// Only make a starter on fairly flat ground.
	//log("hit normal "$HitNormal);
	LastHitLocation = GroundHit;
	HandleStarter(GroundHit, HitNormal, HitVel, DeltaTime);
	HandlePuddle(GroundHit, HitNormal, DeltaTime);
	HandleTrail(GroundHit, HitNormal);

	
/*
	savedist = MAX_FLOAT;
	TouchPuddle=None;
	foreach TraceActors( class 'FuelPuddle', hactor, OutHitLoc, OutHitNorm, EndLoc, StartLoc )
	{
		if( hactor != None )
		{
			// Found some fuel, so increase the size
//			log("hit old one "$OutHitLoc);
			// check to see if it adds some fluid or not, if not, don't say you found a puddle

			FoundPuddle=false;
			// First check the new puddle location against the 
			// current location, then against the end line, 
			// then against the segment itself.
			log("checking :"$hactor.Location);
			rad1 = (hactor.default.UseColRadius + hactor.UseColRadius);
			log("rad1 "$rad1);
			rad2 = VSize(GroundHit - hactor.Location);
			log("rad2 p1 "$rad2);
			if(rad1 > rad2)
				FoundPuddle=true;
			else
			{
				rad2 = VSize(GroundHit - (SuperSpriteEmitter(hactor.Emitters[0]).LineEnd + hactor.Location));
				log("rad2 p2 "$rad2);
				if(rad1 > rad2)
					FoundPuddle=true;
				else
				{
					PointToLineDist(SuperSpriteEmitter(hactor.Emitters[0]).LineStart,
						SuperSpriteEmitter(hactor.Emitters[0]).LineEnd,
						GroundHit - hactor.Location, rad2, u);
					log("rad2 line "$rad2);
					if(u > 0 && u < 1.0 && rad1 > rad2)
					{
						FoundPuddle=true;
						CheckedLine=true;
					}
				}
			}

			if(FoundPuddle)
			{
				if(savedist > rad2)
				{
					// finding closest/best puddle match
					savedist = rad2;
					TouchPuddle=hactor;
					log("found one "$savedist);
				}
			}
			*/
			/*
			if(hactor.CheckTouch(GroundHit, DeltaTime))
			{
				FoundPuddle=true;
				break;
			}
			*/
	/*
		} 
	}

	if(TouchPuddle != None)
	{
		// If a line has been created, then lengthen the stream along the line
		if(SuperSpriteEmitter(TouchPuddle.Emitters[0]).LocationShapeExtend == PTLSE_Line)
		{
			vdist1 = VSize(SuperSpriteEmitter(TouchPuddle.Emitters[0]).LineEnd);
			v1 = Normal(SuperSpriteEmitter(TouchPuddle.Emitters[0]).LineEnd);
			v2 = GroundHit - TouchPuddle.Location;
			vdist2 = VSize(v2);
			v2 = Normal(v2);
			dotcheck =  v2 dot v1;
			//log("v1 : "$v1);
			//log("v2 : "$v2);
			//log("dot :"$dotcheck);

			// If it's farther along the stream than the end of the stream already
			// is. (if not, then it's like adding to the middle of the stream),
			// so nothing happens right now.
			// The second check is to make sure that the full distance of the line emitter
			// has not extended the static cylinder collision radius for the puddle/stream
			// minus the small distance away from the line.
			if(vdist2 > vdist1 && vdist2 < TouchPuddle.default.CollisionRadius - TouchPuddle.default.UseColRadius)
			{
			//	log("vdist2 "$vdist2);
			//	log("vdist1 "$vdist1);
				SuperSpriteEmitter(TouchPuddle.Emitters[0]).LineEnd = vdist2*v1;
			//	log("new end "$SuperSpriteEmitter(TouchPuddle.Emitters[0]).LineEnd);
			}
			// Spawn a new one if your hitting the middle of the stream.
			else if(CheckedLine)
				SpawnANewOne=true;
		}
		else // put it where the new hit is
		{
			SuperSpriteEmitter(TouchPuddle.Emitters[0]).LineEnd = GroundHit - TouchPuddle.Location;
			SuperSpriteEmitter(TouchPuddle.Emitters[0]).LocationShapeExtend=PTLSE_Line;
		}
	}
	else
		SpawnANewOne=true;
//	else

	if(SpawnANewOne)
	{
		log("spawning here "$GroundHit);
		hactor = spawn(class 'FuelPuddle', self,,GroundHit);
	}
	*/
	/*
	// didn't find any fuel, so make some
	if(FoundPuddle==false)
	{
		hactor = spawn(class 'FuelPuddle', self,,GroundHit);
		hactor.CheckToMergePuddles();

//		log("made a new one: "$hactor);
//		log("made it here "$GroundHit);
	}
	*/
}

///////////////////////////////////////////////////////////////////////////
// The fluid is hitting a pawn. 
// Stubbed out for different fluids
///////////////////////////////////////////////////////////////////////////
function HittingPawn(FPSPawn fpawn, vector HitLocation)
{
	log("ERROR: Default hitting pawn");
}

///////////////////////////////////////////////////////////////////////////
// Manually check if you're hitting you're owner, since Trace won't let you
// and we can do it more cheaply
// Do this by checking direction of pouring
///////////////////////////////////////////////////////////////////////////
function HittingOwner(vector Dir)
{
	// STUB	
}

///////////////////////////////////////////////////////////////////////////
// Feeder hit an actor other than a puddle
///////////////////////////////////////////////////////////////////////////
function int FeederHitActor(Actor Other, vector HitLocation, vector HitNormal,
						vector FeederStart, vector FeederEnd, float DeltaTime)
{
	return 0;
}

///////////////////////////////////////////////////////////////////////////
// Collision along this line for the fluid
///////////////////////////////////////////////////////////////////////////
function bool FeederTrace(vector StartPos, 
						  vector EndPos, 
						  vector Vel,
						  float DeltaTime, 
						  int index)
{
	local vector HitLocation, HitNormal, PuddleLocation;
	local Actor FeederCheck, CheckA;
	local FluidPuddle HitPuddle;
	local FluidPuddle KeepPuddle;
	local float dist, keepdist;
	local Actor HitActor;
	local FPSPawn p2p;
	local LambController lambc;
	local int feederreturn;
	local bool bGoodFeederReturn;

	keepdist = MAX_PUDDLE_SIZE;

	HitActor = Trace(HitLocation, HitNormal, EndPos, StartPos, bCanHitActors);

	if(HitActor != None)
	{
		// We hit something, so check again, and see if it was a puddle,
		// if we're not already pouring into a puddle
		if(FPuddle == None)
		{
			//log("checking for puddle");
			foreach TraceActors( class 'Actor', CheckA, PuddleLocation, HitNormal, EndPos, StartPos )
			{
				HitPuddle = FluidPuddle(CheckA);
				//log("hit actor "$HitPuddle);
				if(HitPuddle != None)
				{
					// make sure you're the same liquid type
					if(HitPuddle.MyType == MyType)
					{
						dist = VSize(HitPuddle.Location - PuddleLocation);
						// find the closest puddle
						if(keepdist > dist)
						{
							//log("keeping "$HitPuddle);
							keepdist = dist;
							KeepPuddle = HitPuddle;
						}
					}
				}
				else
				{
					feederreturn = FeederHitActor(CheckA, PuddleLocation, HitNormal,
									StartPos, EndPos, DeltaTime);

					if(feederreturn == 2)
					{
						// use this instead and handle it below, accordingly
						HitActor = CheckA;
						bGoodFeederReturn=true;
						break;
					}
					else if(feederreturn == 1)
					{
						// Save the one(last one) that almost made it
						FeederCheck = CheckA;
					}
				}
			}

			// You found a new puddle, make sure your hit point is within the puddle radius
			if(KeepPuddle != None)
			{
				if(keepdist <= KeepPuddle.UseColRadius + PUDDLE_FUZZ)
				{
					HitLocation = PuddleLocation;
					FPuddle = KeepPuddle;
					//FPuddle.Prev = self;
					FPuddle.CheckToDissolve();
					SeverTrail(0, false);
				}
			}
			// If you didn't find a perfect match, but you found a decent one
			// go ahead and stick with that, because it's our last resort
			// You would have found a puddle and much more before this, if it were valid
			if(!bGoodFeederReturn
				&& FeederCheck != None)
			{
				HitActor = FeederCheck;
			}
		}

		// Turn on the standard splashing...
		if(FSplash != None)
		{
			FSplash.TurnOnSplash();
			FSplash.SetLocation(HitLocation);
			FSplash.FitToNormal(HitNormal);
		}

		p2p = FPSPawn(HitActor);

		//log(self$" hit actor "$HitActor$" bstatic "$HitActor.bStatic);

		if(p2p != None
			&& HitActor != MyOwner)
		{
			// Don't want bubbles here, we want to splash a dead or alive pawn
			HittingPawn(p2p, HitLocation);
		}
		else if(HitActor.bStatic) // hit terrain or anything not allowed to move
		{
			if(bFlowing)
			{
				if(!VectorsInFuzz(HitLocation, StartPos, HIT_LOCATION_FUZZ))
				{
					LastHitPos = HitLocation;
					LastHitNormal = HitNormal;
					ArcIndexHit=index;
					CheckForFluidHit(StartPos, EndPos, Vel, HitLocation, HitNormal, DeltaTime);
				}
			}
		}
		else
		{
			// Deliver no damage, but move it some by the 'fake' damage
			HitActor.TakeDamage(0, Pawn(MyOwner), HitLocation, MomentumTransfer*Vel, MyDamageType);
		}

		return true; // found a collision
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Exploding(vector StartPos)
{
	if(Instigator != None)
		StartPos = Instigator.Location;
	spawn(class'FireWoof',,,StartPos);
	HurtRadius(EXPLODE_DAMAGE, EXPLODE_RADIUS, Class'BaseFx.BurnedDamage', 50000, StartPos );
	SeverLinks(0, false);
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// The feeder itself is on fire, so the source if it
// needs to explode and get hurt really badly
///////////////////////////////////////////////////////////////////////////////
function SetAblaze(vector StartPos, bool NewStart)
{
	//log("SETABLAZE "$self);
	if(!bOnFire
		&& bCanBeDamaged)
		Exploding(StartPos);
}

///////////////////////////////////////////////////////////////////////////////
// This must be extended
///////////////////////////////////////////////////////////////////////////////
simulated function Tick(float DeltaTime)
{
	log(self$": ERROR: stubbed out tick being used");
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
	ignores CheckForFluidHit, Tick;

	function Timer()
	{
		GotoState('Pouring');
	}
	function BeginState()
	{
		//log(self$" start timer with "$StartingTime);
		if(StartingTime > 0)
			SetTimer(StartingTime, false);
		else
			Timer();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TryToMakeAuxFluids()
{
	local vector OldNormal;

	if(TryToMake == MAKE_STARTER)
	{
		if(TrailStarterClass != None)
		{
			//log("SPAWN STARTER ");
			if(FTrail != None
				&& FTrail.Emitters.Length > 0)
				OldNormal = SuperSpriteEmitter(FTrail.Emitters[0]).ProjectionNormal;
			else
				OldNormal = vect(0, 0, 1);
			FStarter = spawn(TrailStarterClass, self,,LastHitLocation);
			FStarter.SetFluidType(MyType);
			FStarter.FeederOwner = self;
			FStarter.StartFirstTrail(OldNormal);
			//log(self$" starter "$FStarter$" made at "$NewSpawnPoint$" on normal "$OldNormal);
		}
	}
	else if(TryToMake == MAKE_PUDDLE)
	{
		if(PuddleClass != None)
		{
			//log(self$" spawn at "$NewSpawnPoint$" feeder location "$Location);
			//if(FTrail != None)
			//	OldNormal = SpriteEmitter(FTrail.Emitters[0]).ProjectionNormal;
			//else
			//	OldNormal = vect(0, 0, 1);
			FPuddle = spawn(PuddleClass, self,,LastHitLocation);
			FPuddle.Instigator = Instigator;
			FPuddle.SetFluidType(MyType);
			if(!bAllowPuddleRipples)
				FPuddle.RemoveRipples();
			//log("my radius "$FPuddle.UseColRadius);
			//FPuddle.Prev = self;

			//log(self$" SPAWN PUDDLE "$FPuddle);
			// Check to dissolve the trail below it
			if(FTrail != None)
			{
				//log("checking to dissolve "$FTrail);
				if(FPuddle.CheckToDissolve(FTrail))
				{
					SeverTrail(0, false);
				//	log("removing trail");
				}
			}
		}
	}
	TryToMake = 0;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// actually pouring
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Pouring
{
	function Timer()
	{
		TryToMakeAuxFluids();
	}
	function EndState()
	{
		bFullyActive=false;
		Super.EndState();
	}
	function BeginState()
	{
		bFullyActive=false;
		Super.EndState();
	}
Begin:
	Sleep(FULLY_ACTIVE_TIME);
	bFullyActive=true;
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
	ignores Tick, ToggleFlow;

	function Timer()
	{
		//SeverLinks();
		//log("KILLING THIS FEEDER "$self);
		Destroy();
	}

	function BeginState()
	{
		SetTimer(0.8, false); // time to kill off this actor
	}
}

defaultproperties
{
    UseColRadius=25
    CollisionHeight=1000.000000
	bNeedsDirectHit=true
	bFlowing=true
	SpawnDripTime=0.3
	TimeToMakePuddle=0.7
	TimeToMakeStarter=0.15
	QuantityPerHit=60
	SplashClass = class'FluidSplashEmitter'
	TrailClass = class'FluidTrail'
	TrailStarterClass = class'FluidTrailStarter'
	PuddleClass = class'FluidPuddle'
	bAllowPuddleRipples=true
	StarterClass=class'FireStarterFollow'
	StartingTime=0.0
	bSkipEncroachmentCheck=True
}

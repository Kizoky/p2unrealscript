///////////////////////////////////////////////////////////////////////////////
// LauncherSeekingProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual rocket that goes flying through the air.
// Seeks a target. Like it's ancestor, it can run out of fuel, and then 
// tumble, still potent, to the ground.
// Can bounce BounceMax-1 before it detonates if not hitting target, or
// on collision with a non-static thing.
//
// This one can slow down after a bump, and turn faster to find it's target,
// then blast off again.
//
///////////////////////////////////////////////////////////////////////////////
class LauncherSeekingProjectile extends LauncherSeekingProjectileTrad;

///////////////////////////////////////////////////////////////////////////////
// Vars and Consts
///////////////////////////////////////////////////////////////////////////////
var Actor SeekingTarget;	// What we're targetting (we want to kill this thing)
var Actor DirectionTarget;	// Target we're currently aiming towards (usually seekingtarget, but
							// sometimes a pathnode to help us steer towards our target better)

var float TargetRadius;		// Radius inside which you can target something
var int   BounceCount;		// How many bounces we've had
var int   BounceMax;		// How many bounces we can sustain, at max or more bounces
							// the rocket will finally detonate.
var int	  WallBounceCount;	// How many times we've bounce a wall consectively
var float SeekReadjustFreq; // This is for how often it tries to reorient to find it's Seeking target
var float BumpReadjustFreq; // Time we take to readjust after a bump
var float ControlledReadjustFreq;	// If the player starts the controlling the rocket, we let him
									// and we wait this long to start recontrolling the rocket
var float SeekingAccelerationMag; // how much acceleration mag you're getting towards your SeekingTarget
var float GravAccZ;			// How much to factor in for gravity
var float ReadjustSpeed;	// The closer to 0 (from 1) this is, the faster it will reorient
var float VelDampenThink;	// Factor you slow down by when you want to readjust after a bounce.
var float JumpstartMag;		// How much to add on to the velocity when you start really seeking again
var float SeekingDot;		// Dot product value inside which the seeking direction and vector between
							// me and my target must form before I start seeking again. Randomly picked
							// each time it bounces.
var float LastBounceTime;	// Last level time you bounced and set bNeedsToThink to true.
var bool  bNeedsToThink;	// Gets set when you bounce, so you'll eventually slow and readjust.
var float HoldTime;			// Level time when you started trying to hold your view on your target
var bool  bHolding;			// You're getting ready to strike


const HELPER_MAX_RADIUS		=	1024;
const HELPER_MIN_RADIUS		=	300;
const HELPER_NEAR_RADIUS	=	150;

const READJUST_SLOW_MAG		=	2.3;	// How much faster to turn when you're going slow
const RAND_RANGE			=	0.3;	// Only let it get this percentage back possibly from a bounce
const ACC_REGAIN			=	10;		// When you're slow, how much acceleration to get back each iteration
										// this is only meant as a fail safe to ensure the thing gets going again
										// eventually
const SEEKING_DOT_RANGE		=	0.05;   // The seeking dot is aiming for -1. A random amount of this value is subtracted
										// from -0.99 to find the value inside which the rocket must be before it
										// takes off again after it's prey
const FLOOR_Z				=	-0.7;	// What we consider a floor

const WALL_HIT_MAX			=	4;		// Max times we can hit a wall before we try to go up
const WAIT_TO_THINK_TIME	=	0.6;	// Wait for this till you slow down after a bounce
const HOLD_AND_THINK_TIME	=	1.0;	// Wait this long after you'e reacquired you're target

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetNewTarget(Actor NewTarget)
{
	SeekingTarget = NewTarget;
	DirectionTarget = SeekingTarget;
	if(P2Pawn(NewTarget) != None
		&& P2Player(P2Pawn(NewTarget).Controller) != None)
		P2Pawn(NewTarget).ClientStartRocketBeeping(self);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function RocketBounceRecoil(vector HitNormal, Actor SoundSource)
{
	local float usedamp;

	if(SeekingTarget != None)
		usedamp = VelDampen;
	else
		usedamp = 1;

	// Reflect and slow down
	Velocity = usedamp * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));

	// Decide if it's a wall
	if(HitNormal.z < FLOOR_Z)
		WallBounceCount++;

	// Bounce up wildly to try getting out of here.
	if(WallBounceCount >= WALL_HIT_MAX)
	{
		WallBounceCount=0;
		Velocity.z +=(FRand()*JumpStartMag);
	}

	// You need to seriously update
	if(!bNeedsToThink)
	{
		bNeedsToThink=true;
		LastBounceTime = Level.TimeSeconds;
		// Check to make sure you're target's not dead
		if(Pawn(SeekingTarget) != None
			&& Pawn(SeekingTarget).Health <= 0)
		{
			ClearSeekingTarget();
		}
	}

	// Jump around a little crazily every time
	Velocity += (MinSpeedForBounce/2)*VRand();

	// Don't let it get too slow
	if(VSize(Velocity) < MinSpeedForBounce)
	{
		Velocity = MinSpeedForBounce*Normal(Velocity);
		// If we did go under, then make sure to bounce off the normal in a crazy manner.
		Velocity += (FRand()*MinSpeedForBounce*HitNormal);
	}

	// play a noise
	SoundSource.PlaySound(RocketBounce,,,,80,GetRandPitch());
}

///////////////////////////////////////////////////////////////////////////////
// After a bump, you'll slow you're acceleration and speed a lot and 
// try to readjust
///////////////////////////////////////////////////////////////////////////////
simulated function DoThinking()
{
	bNeedsToThink=false;

	// If you don't already have a target, try to find one again
	if(SeekingTarget == None)
		DetermineTarget(Location);
	else
	{
		// Drop you're speed significantly
		Velocity = VelDampenThink*Velocity;
		if(VSize(Velocity) < MinSpeedForBounce)
			Velocity = MinSpeedForBounce*Normal(Velocity);
		// Lose some seeking acceleration too
		SeekingAccelerationMag = RAND_RANGE*FRand()*default.SeekingAccelerationMag;
		ReadjustSpeed=READJUST_SLOW_MAG*default.ReadjustSpeed;
		// Decide when to seek again
		SeekingDot = FRand()*SEEKING_DOT_RANGE - 0.99;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flying
// Actually cruising through the air
// And actively seeking your target
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Flying
{
/*
	///////////////////////////////////////////////////////////////////////////////
	// Use a pathnode nearby to steer by for a little while instead of just our
	// seeking target. Only do this if we *don't* have a direct line of sight
	// to our target
	///////////////////////////////////////////////////////////////////////////////
	function UseNearPathNode()
	{
		local PathNode pn, keeppn;
		local vector UseLoc;
		local float checkdist, keepdist, startdist;

		// If we have a target and are not already using a pathnode as a helper to find
		// our way, then try to find one to use.
		if(SeekingTarget != None
			&& SeekingTarget == DirectionTarget
			&& !FastTrace(SeekingTarget.Location, Location))
		{
			// Pick and in between point to check within
			UseLoc = (SeekingTarget.Location + Location)/2;
			startdist = VSize(UseLoc - Location);
			if(startdist > HELPER_MAX_RADIUS)
				startdist = HELPER_MAX_RADIUS;
			else if(startdist < HELPER_MIN_RADIUS)
				startdist = HELPER_MIN_RADIUS;
			keepdist = startdist;

			log(self$" UseNearPathNode "$Location$" target "$SeekingTarget.Location$" in between"$UseLoc);

			foreach RadiusActors(class'PathNode', pn, startdist, UseLoc)
			{
				log(self$" looking at "$pn);
				checkdist = VSize(pn.Location - UseLoc);
				// Make sure we  have a straight shot at this point first too (from our position, not
				// the in between point
				if(checkdist < keepdist
					&& FastTrace(pn.Location, Location))
				{
					keeppn = pn;
					keepdist = checkdist;
				}
			}
			if(keeppn != None)
			{
				log(self$" picking keeppn "$keeppn);
				DirectionTarget = keeppn;
			}
		}
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	// Readjust your direction to find your target
	///////////////////////////////////////////////////////////////////////////////
	simulated function UpdateDirection()
	{
		local vector SeekingDir, VelDir;
		local float MagnitudeVel, dotcheck;
		local String num;
		local FPSPawn usepawn;

		VelDir = Normal(Velocity);

		// If you've bounced recently, consider slowing down
		if(bNeedsToThink
			&& Level.TimeSeconds > LastBounceTime + WAIT_TO_THINK_TIME)
			DoThinking();

		// Stop holding and go after him!
		if(bHolding
			&& Level.TimeSeconds > HoldTime + HOLD_AND_THINK_TIME)
		{
			// Go fast again after the target
			SeekingAccelerationMag = default.SeekingAccelerationMag;
			ReadjustSpeed = default.ReadjustSpeed;
			// Give it an instant, extra boost when starting off again
			MagnitudeVel += JumpstartMag;
			bHolding=false;
		}
		else
			MagnitudeVel=0;

		// Train onto your target
		if (DirectionTarget != None)
		{
			SeekingDir = DirectionTarget.Location - Location;
			// If we're not seeking our target, but seeking something nearby to help us navigate
			// then decide when we're close enough to it
			if(DirectionTarget != SeekingTarget)
			{
				//log(self$" dist to helper "$VSize(SeekingDir));
				if(VSize(SeekingDir) < HELPER_NEAR_RADIUS)
				{
					// Redirect ourself again at the seeking target again
					log(self$" close enough to "$DirectionTarget$" picking seeking again!");
					DirectionTarget = SeekingTarget;
					// Redo this direction, to help it readjust now to original target
					SeekingDir = DirectionTarget.Location - Location;
					// Boost the velocity back to a fast speed!
					Velocity = 2*Velocity;
				}
			}
			SeekingDir = Normal(SeekingDir);
			dotcheck = SeekingDir Dot VelDir;
			if(dotcheck != 0)
			{
				// Add to our mag, in case holding gave us a boost
				MagnitudeVel = MagnitudeVel + VSize(Velocity);
				SeekingDir = Normal(SeekingDir * ReadjustSpeed * MagnitudeVel + Velocity);

				if(!bHolding
					&& SeekingAccelerationMag < default.SeekingAccelerationMag)
				{
					//log(self$" dot "$SeekingDir dot Normal(Location - DirectionTarget.Location));
					if(SeekingDir dot Normal(Location - DirectionTarget.Location) < SeekingDot)
					{
						// Mark that you're tracking him
						HoldTime = Level.TimeSeconds;
						bHolding=true;
					}
					else
						SeekingAccelerationMag += ACC_REGAIN;
				}

				if(DirectionTarget == SeekingTarget)
					Velocity =  MagnitudeVel * SeekingDir;
				else
					Velocity =  MinSpeedForBounce * SeekingDir;

				if(SeekingAccelerationMag >= default.SeekingAccelerationMag)
				{
					Acceleration = SeekingAccelerationMag*SeekingDir;	
					Acceleration.z += GravAccZ;
				}
				else
				{
					Acceleration.x=0;
					Acceleration.y=0;
					Acceleration.z=GravAccZ;
				}
			}
		}

		// Check to run out of fuel
		// Looks here to find out if it's out fuel instead of 
		// using the single timer like in the normal rocket to 
		// tell it when it's out of fuel. A little slower, but
		// this doesn't get called constantly. 
		if(LifeSpan < FallAfterNoFuelTime)
		{
			StartTumbling();
		}
		else
		{
			UpdateCount++;
			// Tell our seeking target we're after them
			if(UpdateCount == MAX_UPDATES)
			{
				usepawn = FPSPawn(SeekingTarget);
				if(usepawn != None
					&& LambController(usepawn.Controller) != None)
					LambController(usepawn.Controller).RocketIsAfterMe(FPSPawn(Instigator), self);
				UpdateCount = 0;
			}
		}
	}

Begin:
	Sleep(SeekReadjustFreq);
	UpdateDirection();
	Goto('Begin');
Bumped:
	Sleep(BumpReadjustFreq);
	UpdateDirection();
	Goto('Begin');
Controlled:
	Sleep(ControlledReadjustFreq);
	UpdateDirection();
	Goto('Begin');
}

defaultproperties
{
	Skins[0]=Texture'WeaponSkins.rocket_seeking'
    MaxSpeed=1300.000000
	BlastOffVelMag=200
	ForwardAccelerationMag=300
	JumpstartMag=350
	TargetRadius=2000
	bBounce=true
	MinSpeedForBounce=200
	BounceMax=1000
	VelDampenThink=0.3
	VelDampen=0.9
	RotDampen=0.9
	CollisionHeight=40
	CollisionRadius=40
	StartSpinMag=0
	SeekReadjustFreq=0.1
	BumpReadjustFreq=0.4
	ControlledReadjustFreq=1.0
	SeekingAccelerationMag=300
	GravAccZ=-20.0
	LifeSpan=30
	ReadjustSpeed=0.15
	SeekingDot=-0.95
}

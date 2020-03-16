///////////////////////////////////////////////////////////////////////////////
// LauncherSeekingProjectileTrad.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual rocket that goes flying through the air.
// Seeks a target. Like it's ancestor, it can run out of fuel, and then 
// tumble, still potent, to the ground.
// Can bounce BounceMax-1 before it detonates if not hitting target, or
// on collision with a non-static thing.
//
// Traditional seeking method. Bounces around a lot more than new(current) seeker.
//
///////////////////////////////////////////////////////////////////////////////
class LauncherSeekingProjectileTrad extends LauncherProjectile;

///////////////////////////////////////////////////////////////////////////////
// Vars and Consts
///////////////////////////////////////////////////////////////////////////////
var Actor SeekingTarget;	// What we're targetting

var float TargetRadius;		// Radius inside which you can target something
var byte  BounceCount;		// How many bounces we've had
var byte  BounceMax;		// How many bounces we can sustain, at max or more bounces
							// the rocket will finally detonate.
var float SeekReadjustFreq; // This is for how often it tries to reorient to find it's Seeking target
var float BumpReadjustFreq; // Time we take to readjust after a bump
var float ControlledReadjustFreq;	// If the player starts the controlling the rocket, we let him
									// and we wait this long to start recontrolling the rocket
var float SeekingAccelerationMag; // how much acceleration mag you're getting towards your SeekingTarget
var float GravAccZ;			// How much to factor in for gravity
var float ReadjustSpeed;	// The closer to 0 (from 1) this is, the faster it will reorient
var byte  UpdateCount;		// Number of times you've updatted. Wrap to 0 when you cross the max.
							// Default it to start about halfway there, so it alerts people right
							// off the bat sooner, then cycles for a while.


const MAX_UPDATES			=	13;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	ClearSeekingTarget();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetNewTarget(Actor NewTarget)
{
	// Set your new target
	SeekingTarget = NewTarget;

	// Tell the guy your after to start beeping
	if(P2Pawn(NewTarget) != None
		&& P2Player(P2Pawn(NewTarget).Controller) != None)
		P2Pawn(NewTarget).ClientStartRocketBeeping(self);
}

///////////////////////////////////////////////////////////////////////////////
// Pick your target
///////////////////////////////////////////////////////////////////////////////
function DetermineTarget(vector FromHere)
{
	local FPSPawn checkp, keepp;
	local float checkdist, keepdist, checkthreat, keepthreat;
	local Controller UseCont, ThisPlayer;

	// NPC's always hit their attacker if they have one
	if(Instigator != None
		&& PersonController(Instigator.Controller) != None
		&& PersonController(Instigator.Controller).Attacker != None
		&& PersonController(Instigator.Controller).Attacker.Health > 0)
	{
		keepp = PersonController(Instigator.Controller).Attacker;
	}

	// Player targetting
	if(keepp == None)
	{
		keepdist = TargetRadius;

		// In the single player, only let the seeker search an area
		if(P2GameInfoSingle(Level.Game) != None)
		{
			foreach VisibleCollidingActors(class'FPSPawn', checkp, TargetRadius, FromHere)
			{
				// Don't let it target player, or dead things, or people that are your friend.
				if(checkp != Instigator
					&& checkp.Health > 0
					&& !checkp.bPlayerIsFriend)
				{
					if(keepp == None)
						keepp = checkp;
					else
					{
						checkdist = VSize(checkp.Location - FromHere);
						//checkthreat = checkp.DetermineThreat();
						if(checkdist < keepdist)
							//|| checkthreat > keepthreat )
						{
							keepthreat = checkthreat;
							keepdist = checkdist;
							keepp = checkp;
						}
					}
				}
			}
		}
		else
		{
			if(Instigator != None)
				ThisPlayer = Instigator.Controller;
			for (UseCont=Level.ControllerList; UseCont!=None; UseCont=UseCont.NextController )
				if ( UseCont != None
					&& UseCont.PlayerReplicationInfo != None)
				{
					// Don't let it target player, or dead things, or people that are your friend.
					if(UseCont.Pawn != Instigator
						&& UseCont.Pawn.Health > 0
						&& (ThisPlayer.PlayerReplicationInfo == None
							|| ThisPlayer.PlayerReplicationInfo.Team == None
							|| UseCont.PlayerReplicationInfo.Team.TeamIndex != ThisPlayer.PlayerReplicationInfo.Team.TeamIndex))
					{
						if(keepp == None)
						{
							keepdist = VSize(UseCont.Pawn.Location - FromHere);
							keepp = FPSPawn(UseCont.Pawn);
						}
						else
						{
							checkdist = VSize(UseCont.Pawn.Location - FromHere);
							if(checkdist < keepdist)
								//|| checkthreat > keepthreat )
							{
								keepthreat = checkthreat;
								keepdist = checkdist;
								keepp = FPSPawn(UseCont.Pawn);
							}
						}
					}
				}
		}
	}

	SetNewTarget(keepp);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClearSeekingTarget()
{
	SeekingTarget=None;
	// Get rid of any beepers you had before
	CheckToKillBeeper();
}
 
///////////////////////////////////////////////////////////////////////////////
// Make the beeping stop on the old target
///////////////////////////////////////////////////////////////////////////////
simulated function CheckToKillBeeper()
{
	local RocketBeeper checkbeep, killbeep;

	foreach DynamicActors(class'RocketBeeper', checkbeep)
	{
		if(checkbeep.RocketOwner == self)
		{
			killbeep = checkbeep;
			break;
		}
	}

	if(killbeep != None)
		killbeep.Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function RocketBounceRecoil(vector HitNormal, Actor SoundSource)
{
	Velocity = VelDampen * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	// play a noise
	SoundSource.PlaySound(RocketBounce,,,,80,GetRandPitch());

	// Check to make sure you're target's not dead
	if(Pawn(SeekingTarget) != None
		&& Pawn(SeekingTarget).Health <= 0)
		ClearSeekingTarget();
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off anything that's not your target, in a reflective manner
// and record the bounce. 
///////////////////////////////////////////////////////////////////////////////
simulated function BounceOffSomething( vector HitNormal, actor Wall )
{
	local vector newhit, newnormal, EndPt;
	local bool bStopped;
	local float speed;
	local SparkHit spark1;
	
	if(bBounce == true)
	{
		BounceCount++;

		// if you're at your max, detonate instead
		if(BounceCount >= BounceMax)
		{
			GenExplosion(Location, HitNormal, Wall);
			return;
		}

		// Fall limply after a bounce
		Acceleration.X=0;
		Acceleration.Y=0;
		Acceleration.Z=GravAccZ;
		// Cough
		EmitSmokePuff(1.0);
		// Throw off some sparks from the hit
		spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(HitNormal));

		RocketBounceRecoil(HitNormal, spark1);

		// Now that you've bounced off something, don't be able to readjust your
		// velocity and direction for a moment
		GotoState('Flying', 'Bumped');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Explode when you hit a non-static object or if you've bounced too much
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	// try to bounce off static stuff
	if(Other.bStatic)
	{
		BounceOffSomething(-Velocity, Other);
	}
	else
	{
		Super.ProcessTouch(Other, HitLocation);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Try to bounce off walls. Blow up if you've bounced too much
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	BounceOffSomething(HitNormal, Wall);
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
	///////////////////////////////////////////////////////////////////////////////
	// Check to see if the player is changing our trajectory
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		local P2Player p2p;
		local float PlayerTurnX, PlayerTurnY, usemult;
		local vector x1, y1, z1;

		// If he's got a camera on it, let him control the rocket some
		if(Instigator != None)
		{
			p2p = P2Player(Instigator.Controller);
			if(p2p != None
				&& p2p.bUseRocketCameras
				&& p2p.ViewTarget == self)
			{
				// Influence the direction of the rocket
				p2p.ModifyRocketMotion(PlayerTurnX, PlayerTurnY);
				if(PlayerTurnX != 0.0
					|| PlayerTurnY != 0.0)
				{
					if(ControlMult < CONTROL_MULT_MAX)
						ControlMult++;
					usemult = (ROCKET_MOVE_BASE + (ROCKET_MOVE_ADD*ControlMult));
					PlayerTurnX*=usemult;
					PlayerTurnY*=usemult;
					//log(self$" tell rocket to move x "$PlayerTurnX$" y "$PlayerTurnY$" my vel "$Velocity$" control "$ControlMult);
					GetAxes(Rotation, x1, y1, z1);
					// We need z1 and y1 the way their are because of the rotation of the rocket
					Velocity += PlayerTurnY*z1 + PlayerTurnX*y1;
					SetRotation(rotator(Velocity));
					// Setup the new acceleration in this direction
					Acceleration = SeekingAccelerationMag*Normal(Velocity);
					Acceleration.z += GravAccZ;
					GotoState('Flying', 'Controlled');
					return;
				}
				else
				{
					if(ControlMult > 0)
						ControlMult--;
				}
			}
		}
		// Update angle
		SetRotation(rotator(Velocity));
	}

	///////////////////////////////////////////////////////////////////////////////
	// Run out of fuel and fall to the ground
	///////////////////////////////////////////////////////////////////////////////
	simulated function StartTumbling()
	{
		// make sure you'll explode on any contact
		BounceCount = BounceMax;
		Super.StartTumbling();
	}

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

		if (SeekingTarget != None)
		{
			SeekingDir = Normal(SeekingTarget.Location - Location);
			dotcheck = SeekingDir Dot VelDir;
			if(dotcheck != 0)
			{
				MagnitudeVel = VSize(Velocity);
				SeekingDir = Normal(SeekingDir * ReadjustSpeed * MagnitudeVel + Velocity);
				Velocity =  MagnitudeVel * SeekingDir;
				Acceleration = SeekingAccelerationMag*SeekingDir;	
				Acceleration.z += GravAccZ;
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

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		local P2Player p2p;

		BlastOff();

		// Play flying sound
		Timer();

		// Turn on camera if necessary
		if(Instigator != None)
			p2p = P2Player(Instigator.Controller);
		if(p2p != None
			&& p2p.bUseRocketCameras)
			// Make the rocket the view target
			p2p.StartViewingRocket(self);
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
  	NoDamageTime=1.0
	MaxSpeed=1500.000000
	BlastOffVelMag=200
	ForwardAccelerationMag=1500
	TargetRadius=4096
	bBounce=true
	MinSpeedForBounce=100
	BounceMax=1000
	VelDampen=0.95
	RotDampen=0.9
	CollisionHeight=40
	CollisionRadius=40
	StartSpinMag=0
	SeekReadjustFreq=0.1
	BumpReadjustFreq=0.3
	ControlledReadjustFreq=1.0
	SeekingAccelerationMag=100
	GravAccZ=-20
	LifeSpan=30
	UpdateCount=8
	ReadjustSpeed=0.2
}

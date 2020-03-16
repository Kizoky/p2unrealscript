///////////////////////////////////////////////////////////////////////////////
// PlagueProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Straight flying rocket tipped with chemicals. Doesn't 'jump'. Shoots straight.
// Detonates on contact with anything. 
// Not really concerned about fuel in this one. 
// 
///////////////////////////////////////////////////////////////////////////////
class PlagueProjectile extends P2Projectile;

///////////////////////////////////////////////////////////////////////////////
// Vars and Consts
///////////////////////////////////////////////////////////////////////////////
var P2Emitter Trail;					// smoke trail

var float	ForwardAccelerationMag;		// how much acceleration mag after you've gotten going
var float	DefaultFuelTime;			// How much flying fuel you get to start
var float	FallAfterNoFuelTime;		// How long you fall for, after you're out of fuel
var float	BlastOffVelMag;				// Addition to velocity once you take off
var Sound   RocketFlying;
var Sound	RocketBounce;
var Sound	RocketLaunch;
var float   NoDamageTime;				// Let them get going at least a little before you allow
										// them to be shot
var float   StartFlyTime;				// Time after eject that we started flying

// When you're being controlled
var int		ControlMult;				// How touchy the controls are, higher, the more you
										// move with each touch of the player.
var float	GravAccZ;					// Acceleration for our gravity


const FORCE_RAD_CHECK	=	50;			// Distance to the wall to check for attaching
										// the rocket force to a wall (instead of having the force
										// applied at the explosion epicenter--this is to make sure
										// things get thrown up and away more often.

const ROCKET_MOVE_BASE	=	1500.0;		// Base movement mult for controlling the rocket
const ROCKET_MOVE_ADD	=	500.0;		// Multiplied by ControlMult to add to the movement factor
const CONTROL_MULT_MAX	=	10;			// How high ControlMult can get.
const DEFLECT_RATIO		=	0.5;		// How much to the sides you can deflect a rocket with a kick

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if ( Trail != None )
	{
		Trail.SelfDestroy();
		Trail = None;
	}

	// Stop all sounds
	PlaySound(RocketLaunch, SLOT_Misc, 0.01, false, 512.0, 1.0);

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Send it with a certain speed and arm it
///////////////////////////////////////////////////////////////////////////////
function SetupShot(float ChargeTime)
{
	local vector Dir;

	Dir = vector(Rotation);

	Velocity = speed * Dir;

	// set your 'fuel'
	LifeSpan = ChargeTime + DefaultFuelTime + FallAfterNoFuelTime;
}

///////////////////////////////////////////////////////////////////////////////
// Explode on contact with walls.. people.. everything else makes you bounce off 
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ((Pawn(Other) != None
			&& Pawn(Other).Health > 0))
	{
		if(Other != Instigator)
		{
			GenExplosion(HitLocation,-Normal(Velocity), Other);
		}
	}
	else if(Other != self)
	{
		Other.Bump(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Something has happened, the engine quit, we bumped something, so
// emit a smoke puff
///////////////////////////////////////////////////////////////////////////////
function EmitSmokePuff(float UseScale)
{
	local RocketSmokePuff smokep;

	smokep = spawn(class'Fx.RocketSmokePuff',Owner,,Location);

	smokep.ScaleEffect(UseScale);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	GenExplosion(Location, HitNormal, Wall);
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off anything that's not your target, in a reflective manner
// and record the bounce. 
///////////////////////////////////////////////////////////////////////////////
function BounceOffSomething( vector HitNormal, actor Wall )
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
//	local PlagueExplosion exp;
//	local vector WallHitPoint, OrigLoc;
//	local Actor ViewThing;

	local PlagueExplosion exp;
	exp = spawn(class'PlagueExplosion',GetMaker(),,HitLocation);
	exp.UseNormal = HitNormal;
	exp.ShakeCamera(exp.ExplosionDamage);
	exp.ImpactActor = Other;

 	Destroy();
/*
	if(Other != None
		&& Other.bStatic)
	{
		// Make sure the force of this explosion is all the way against the wall that
		// we hit
		OrigLoc = HitLocation;
		WallHitPoint = HitLocation - FORCE_RAD_CHECK*HitNormal;
		if(Trace(HitLocation, HitNormal, WallHitPoint, HitLocation) == None)
		{
			HitLocation = OrigLoc;
			WallHitPoint = OrigLoc;
		}
	}
	else
		WallHitPoint = HitLocation;

	exp = spawn(class'PlagueExplosion',,,HitLocation + ExploWallOut*HitNormal);
	exp.CheckForHitType(Other);
	exp.ShakeCamera(exp.ExplosionDamage);
	exp.ForceLocation = WallHitPoint;

	// If we're controlling this particular rocket, tell the player about it
	if(Instigator != None
		&& P2Player(Instigator.Controller) != None
		&& P2Player(Instigator.Controller).ViewTarget == self)
	{
		// If we hit a person or animal or interesting thing, view it directly
		if(FPSPawn(Other) != None)
			ViewThing = Other;
		else // Otherwise, just watch the pretty explosion
			ViewThing = exp;
		P2Player(Instigator.Controller).RocketDetonated(ViewThing);
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
//		spawn(class'BlastMark',,,,rot(16384,0,0));
//  		spawn(class'PclCOGRocketReallyBigExplosion',,,HitLocation,rot(16384,0,0));
	}
 	Destroy();
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Base level takedamage
///////////////////////////////////////////////////////////////////////////////
function BaseTakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	local vector HitNormal;

	// Don't do anything if there's no damage
	if(Dam <= 0)
		return;

	// Bludgeoning can deflect rockets
	if(ClassIsChildOf(damageType, class'BludgeonDamage'))
	{
		// Pick a direction to deflect it in
		HitNormal = Normal(DEFLECT_RATIO*VRand() - Normal(Velocity));

		// Hurt it so that it's health represents each kick you can
		// give it, before it blows up
		// Health-=1;
		// Don't take health anymore--let them kick it an infinite number of times

		if(Health <= 0)
		{
			GenExplosion(HitLocation, vect(0, 0, 1), None);
			return;
		}
		else
		{
			// If we only need one more hit before we blow up, start glowing
			if(Health == 1)
				AmbientGlow = 255;

			BounceOffSomething(HitNormal, InstigatedBy);
		}
	}
	else
	{

		// Only bullets can blow up rockets
		if(!ClassIsChildOf(damageType, class'BulletDamage'))
			return;

		Health-=Dam;
		if(Health <= 0)
		{
			GenExplosion(HitLocation, vect(0, 0, 1), None);
			return;
		}
		// Now add in momentum if we didn't explode
		Velocity+=(Momentum/Mass);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Eject
// Popping out of the launcher and getting ready to fly
// This style of rocket doesn't use this state. It is burning fuel immediately
// out of the tube. 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Eject
{
	ignores TakeDamage;	 // so they won't blow up right outta the launcher.

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		// STUB, don't update your rotation here
	}

	///////////////////////////////////////////////////////////////////////////////
	// Bumped an actor
	///////////////////////////////////////////////////////////////////////////////
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		// If two hit in the air, they both explode
		if(PlagueProjectile(Other) != None)
		{
			GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
			PlagueProjectile(Other).GenExplosion(HitLocation,Normal(Other.Location-HitLocation), self);
		}
		// Detonates on pawns
		else if ((Pawn(Other) != None
				&& Pawn(Other).Health > 0))
		{
			if(Other != Instigator)
			{
				GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
			}
		}
		// Bumps other projectiles (like grenades)
		else if(Projectile(Other) == None)
		{
			Other.Bump(self);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Ready to fly
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		StartFlyTime=Level.TimeSeconds;
		GotoState('Flying');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		//log(self$" eject");
		//PlayAnim('Still', 0.1);
		SetTimer(0.4, false);
		// We jumped out, so make a smoke puff nearby
		EmitSmokePuff(0.3);

		PlaySound(RocketLaunch, SLOT_Misc, 1.0, false, 512.0, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flying
// Actually cruising through the air
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Flying extends Eject
{
	///////////////////////////////////////////////////////////////////////////////
	// Rockets can sometimes be controlled by the player
	///////////////////////////////////////////////////////////////////////////////
	function bool AllowControl()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
								Vector momentum, class<DamageType> damageType)
	{
		//log(self$" take damage "$Level.TimeSeconds - StartFlyTime);
		if((Level.TimeSeconds - StartFlyTime) > NoDamageTime)
		{
			BaseTakeDamage(Dam, InstigatedBy, HitLocation, Momentum, DamageType);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Play your movement noise again
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		PlaySound(RocketFlying, SLOT_Misc, 1.0, false, 512.0, 1.0);
		SetTimer(GetSoundDuration(RocketFlying), false);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Run out of fuel and fall to the ground
	///////////////////////////////////////////////////////////////////////////////
	function StartTumbling()
	{
		// Start falling (tumbling) because you ran out of fuel
		// but only do this once
		Acceleration = default.Acceleration;
		Acceleration.z += GravAccZ;
		Velocity.x = Velocity.x/2;
		Velocity.y = Velocity.y/2;
		if(Velocity.z > 0)
			Velocity.z = Velocity.z/2;
		RotationRate.Pitch = -8000;
		RotationRate.Roll = 0;
		
		// Kill the fire
		if(Trail != None)
			Trail.SelfDestroyOne(2);
		// and cough
		EmitSmokePuff(1.3);
		// And finall tumble
		GotoState('Tumbling');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Start moving and shoot out flames and smoke
	///////////////////////////////////////////////////////////////////////////////
	function BlastOff()
	{
		local vector Dir;

		Dir = vector(Rotation);
		// blast off
		Velocity += BlastOffVelMag*Dir;
		//Velocity.z/=8;
		Acceleration = ForwardAccelerationMag*Dir;

		if ( Trail == None )
		{
			Trail = spawn(class'Fx.RocketPlagueTrail',Owner,,Location);
			Trail.SetBase(self);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// End flying noise
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		AmbientSound = None;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local P2Player p2p;

		BlastOff();
		StartFlyTime=Level.TimeSeconds;
		// Play flying sound
		Timer();
	}
Begin:
	// After this time make the rocket fall for lack of fuel before 
	// a given amount of time, before it's supposed to die.
	Sleep(LifeSpan - FallAfterNoFuelTime);
	StartTumbling();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Tumbling
// Out of fuel, falling to the ground. Blow up when you hit anything here.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Tumbling extends Eject
{
	ignores Timer;
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		GenExplosion(HitLocation,-Normal(Velocity), Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function HitWall( vector HitNormal, actor Wall )
	{
		GenExplosion(Location, HitNormal, Wall);
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
								Vector momentum, class<DamageType> damageType)
	{
		BaseTakeDamage(Dam, InstigatedBy, HitLocation, Momentum, DamageType);
	}
	function BeginState()
	{
		PlaySound(RocketLaunch, SLOT_Misc, 0.01, false, 512.0, 1.0);
	}
}

defaultproperties
{
 	NoDamageTime=0.3
	Speed=250.000000
    MaxSpeed=5000.000000
	Damage=0.000000	// these two are handled in the FX explosion
	DamageRadius=0.0
	MomentumTransfer=100000.000000
	MyDamageType=class'ExplodedDamage'
	LifeSpan=20.000000
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Patch1_mesh.Weapons.WMD_Rocket'
	AmbientGlow=96
	bBounce=false
	bFixedRotationDir=true
	ForceType=FT_DragAlong
	ForceRadius=100.000000
	ForceScale=4.000000
	VelDampen=0.99
	//DrawScale3D=(X=1.5,Y=1.0,Z=1.0)
	CollisionHeight=30.0
	CollisionRadius=30.0
	Health=2
	GravAccZ=0
	ForwardAccelerationMag=1500
	DefaultFuelTime=0.75
	FallAfterNoFuelTime=10.0
	BlastOffVelMag=400
	TossZ=+280.0
    ExploWallOut=0
	bProjTarget=true
	bUseCylinderCollision=true
	RocketLaunch=Sound'WeaponSounds.rocket_launch'
	RocketFlying=Sound'WeaponSounds.rocket_flying'
	RocketBounce=Sound'WeaponSounds.rocket_bounce'
}

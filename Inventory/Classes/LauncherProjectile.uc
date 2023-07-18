///////////////////////////////////////////////////////////////////////////////
// LauncherProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual rocket that goes flying through the air.
// It fires straight, but it can run out fuel, at which point it tumbles
// to the ground, still potent.
// Detonates on contact with anything. 
//
///////////////////////////////////////////////////////////////////////////////
class LauncherProjectile extends P2Projectile;

///////////////////////////////////////////////////////////////////////////////
// Vars and Consts
///////////////////////////////////////////////////////////////////////////////
var P2Emitter STrail;					// smoke trail
var P2Emitter FTrail;					// fire trail

var bool bCatRider;

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


const FORCE_RAD_CHECK	=	50;			// Distance to the wall to check for attaching
										// the rocket force to a wall (instead of having the force
										// applied at the explosion epicenter--this is to make sure
										// things get thrown up and away more often.

const ROCKET_MOVE_BASE	=	1500.0;		// Base movement mult for controlling the rocket
const ROCKET_MOVE_ADD	=	500.0;		// Multiplied by ControlMult to add to the movement factor
const CONTROL_MULT_MAX	=	10;			// How high ControlMult can get.
const SEEKING_DEFLECT_RATIO	=0.5;		// How much to the sides you can deflect a rocket with a kick
const DEFLECT_RATIO		=	0.05;		// Crazily add just a little to deflect normal rockets.

replication
{
	reliable if(Role==ROLE_Authority)
		ClientStartTumbling;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if ( STrail != None )
	{
		STrail.SelfDestroy();
		STrail = None;
	}
	if ( FTrail != None )
	{
		FTrail.Destroy();
		FTrail = None;
	}

	// Stop all sounds
	PlaySound(RocketLaunch, SLOT_Misc, 0.01, false, 512.0, 1.0);

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Server uses this to force client into NewState
///////////////////////////////////////////////////////////////////////////////
simulated function ClientGotoState(name NewState, optional name NewLabel)
{
	if(Role != ROLE_Authority)
	    GotoState(NewState,NewLabel);
}

///////////////////////////////////////////////////////////////////////////////
// Send it with a certain speed and arm it
///////////////////////////////////////////////////////////////////////////////
function SetupShot(float ChargeTime)
{
	local vector Dir;

	Dir = vector(Rotation);

	// set your 'fuel'
	LifeSpan = ChargeTime + DefaultFuelTime + FallAfterNoFuelTime;
	//log(self$" setupshot "$ChargeTime$" lifespan "$LifeSpan);

	Velocity = speed * Dir;
	Velocity.z += TossZ;
}

///////////////////////////////////////////////////////////////////////////////
// Explode on contact with walls.. people.. everything else makes you bounce off 
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (LauncherProjectile(Other) != none &&
	   (Instigator == LauncherProjectile(Other).Instigator ||
	    Dropper == LauncherProjectile(Other).Dropper))
		return;
	
	if ((Pawn(Other) != None
			&& Pawn(Other).Health > 0))
	{
		if(!RelatedToMe(Pawn(Other)))
		{
			GenExplosion(HitLocation,-Normal(Velocity), Other);
		}
	}
	else
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
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local RocketExplosion exp;
	local vector WallHitPoint, OrigLoc;
	local Actor ViewThing;

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

	exp = spawn(class'RocketExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
	exp.CheckForHitType(Other);
	exp.ShakeCamera(exp.ExplosionDamage);
	exp.ForceLocation = WallHitPoint;

	// xPatch:
	if( bCatRider )
		spawn(class'MeatExplosion', self,, Location);
	// End

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

 	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off anything that's not your target, in a reflective manner
// and record the bounce. 
///////////////////////////////////////////////////////////////////////////////
function BounceOffSomething( vector HitNormal, actor Wall )
{
	local vector newhit, newnormal, EndPt;
	local bool bStopped;
	local float speed;
	local SparkHit spark1;
	
	// Cough
	//EmitSmokePuff(1.0);
	// Throw off some sparks from the hit
	spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(HitNormal));

	// Update velocity
	Velocity = VelDampen * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));

	// Update direction
	SetRotation(rotator(Velocity));

	Acceleration = ForwardAccelerationMag*Normal(Velocity);

	//log(self$" bounce off something, vel "$Velocity$" acc "$Acceleration);
	// play a noise
	Wall.PlaySound(RocketBounce,,,,80,GetRandPitch());
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
		// Pick a direction to deflect it in (falling or non-seeking rockets are 
		// kicked in a more predictable direction)
		if(LauncherSeekingProjectileTrad(self) == None
			|| IsInState('Tumbling'))
			HitNormal = Normal(DEFLECT_RATIO*VRand() + Normal(Momentum));
		else
			HitNormal = Normal(SEEKING_DEFLECT_RATIO*VRand() + Normal(Momentum));

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

		// Make sure the one that blew it up gets the points for doing it.
		TransferInstigator(InstigatedBy);

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
// Run out of fuel and fall to the ground
///////////////////////////////////////////////////////////////////////////////
simulated function ClientStartTumbling()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Eject
// Popping out of the launcher and getting ready to fly
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Eject
{
	ignores TakeDamage;	 // so they won't blow up right outta the launcher.

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		// STUB, don't update your rotation here
	}

	///////////////////////////////////////////////////////////////////////////////
	// Bumped an actor
	///////////////////////////////////////////////////////////////////////////////
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (LauncherProjectile(Other) != none &&
	       (Instigator == LauncherProjectile(Other).Instigator ||
	        Dropper == LauncherProjectile(Other).Dropper))
		    return;
		
		// If two hit in the air, they both explode
		if(LauncherProjectile(Other) != None)
		{
			GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
			LauncherProjectile(Other).GenExplosion(HitLocation,Normal(Other.Location-HitLocation), self);
		}
		// Detonates on pawns
		else if ((Pawn(Other) != None
				&& Pawn(Other).Health > 0))
		{
			if(!RelatedToMe(Pawn(Other)))
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
	simulated function BeginState()
	{
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
state Flying extends Eject
{
	///////////////////////////////////////////////////////////////////////////////
	// Rockets can sometimes be controlled by the player
	///////////////////////////////////////////////////////////////////////////////
	function bool AllowControl()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if the player is changing our trajectory
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local P2Player p2p;
		local float PlayerTurnX, PlayerTurnY, usemult;
		local vector x1, y1, z1;

		// If he's got a camera on it, let him control the rocket some
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
				Acceleration = ForwardAccelerationMag*Normal(Velocity);
				//log(self$" vel after "$Velocity);
				SetRotation(rotator(Velocity));
			}
			else
			{
				if(ControlMult > 0)
					ControlMult--;
			}
		}
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
		Velocity.x = Velocity.x/2;
		Velocity.y = Velocity.y/2;
		if(Velocity.z > 0)
			Velocity.z = Velocity.z/2;
		RotationRate.Pitch = -8000;
		RotationRate.Roll = 0;
		
		// Kill the fire
		if(FTrail != None)
		{
			FTrail.Destroy();
			FTrail=None;
		}
		// and cough
		EmitSmokePuff(1.3);
		// And finally tumble
		GotoState('Tumbling');
		// Bring client version up to speed (haha!)
		if(P2GameInfoSingle(Level.Game) == None
			&& Role == ROLE_Authority)
			ClientStartTumbling();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Run out of fuel and fall to the ground
	///////////////////////////////////////////////////////////////////////////////
	simulated function ClientStartTumbling()
	{
		// Start falling (tumbling) because you ran out of fuel
		// but only do this once
		Acceleration = default.Acceleration;
		Velocity.x = Velocity.x/2;
		Velocity.y = Velocity.y/2;
		if(Velocity.z > 0)
			Velocity.z = Velocity.z/2;
		RotationRate.Pitch = -8000;
		RotationRate.Roll = 0;

		// Kill the fire
		if(FTrail != None)
		{
			FTrail.Destroy();
			FTrail=None;
		}

		// And finally tumble
		GotoState('Tumbling');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Start moving and shoot out flames and smoke
	///////////////////////////////////////////////////////////////////////////////
	simulated function BlastOff()
	{
		local vector Dir;
		local Actor useowner;

		Dir = vector(Rotation);
		// blast off
		Velocity += BlastOffVelMag*Dir;
		//Velocity.z/=8;
		Acceleration = ForwardAccelerationMag*Dir;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if(Level.Game == None
				|| !Level.Game.bIsSinglePlayer)
				useowner = self;
			else // Send player as owner so it will keep up in slomo time
				useowner = Owner;

			// Send player as owner so it will keep up in slomo time
			if(STrail == None )
			{
				STrail = spawn(class'Fx.RocketTrail',useowner,,Location);
				if(Level.Game != None
					&& Level.Game.bIsSinglePlayer)
					STrail.SetBase(self);
			}
			if (FTrail == None )
			{
				FTrail = spawn(class'Fx.RocketFire',useowner,,Location);
				FTrail.SetBase(self);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// End flying noise
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		AmbientSound = None;
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
		{
			p2p = P2Player(Instigator.Controller);
			if(p2p != None
				&& p2p.bUseRocketCameras)
				// Make the rocket the view target
				p2p.StartViewingRocket(self);
		}
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
		if (LauncherProjectile(Other) != none &&
	       (Instigator == LauncherProjectile(Other).Instigator ||
	        Dropper == LauncherProjectile(Other).Dropper))
		    return;
		
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
		Acceleration = default.Acceleration;
	}
	simulated function BeginState()
	{
		// stop sounds
		PlaySound(RocketLaunch, SLOT_Misc, 0.01, false, 512.0, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: It's now catable, ported from Happy Night
///////////////////////////////////////////////////////////////////////////////
function CatConvert(Material CatSkin)
{
	SetDrawType(DT_Mesh);
	LinkMesh(Mesh);
	if( CatSkin != None )
		Skins[0] = CatSkin;
	LoopAnim('fall');
	AmbientSound = Sound'AnimalSounds.Cat.CatScream_loop1';
	RocketBounce = Sound'WeaponSounds.flesh_explode';
	bCatRider = true;
}

defaultproperties
{
 	Mesh=SkeletalMesh'Animals.meshCat'
	NoDamageTime=0.3
	Speed=250.000000
    MaxSpeed=5000.000000
	Damage=0.000000	// these two are handled in the FX explosion
	DamageRadius=0.0
	MomentumTransfer=100000.000000
	MyDamageType=class'RocketDamage'
	//AmbientSound=Sound'WeaponSounds.rocket_flying'
    //SoundVolume=255
    //SoundRadius=100
	LifeSpan=6.000000
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.launcherrocket'
	AmbientGlow=96
	bBounce=false
	bFixedRotationDir=true
	ForceType=FT_DragAlong
	ForceRadius=100.000000
	ForceScale=4.000000
	CollisionHeight=22.0
	CollisionRadius=22.0
	Health=2
	Acceleration=(Z=-1000)
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
	bNetTemporary=false
	bUpdateSimulatedPosition=true
	VelDampen=0.9
}

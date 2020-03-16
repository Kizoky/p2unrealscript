///////////////////////////////////////////////////////////////////////////////
// NapalmProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual napalm cannister that goes flying through the air.
//
///////////////////////////////////////////////////////////////////////////////
class NapalmProjectile extends P2Projectile;

var byte	BounceCount;		// Number of times we've bounced
var float	FirstBounceSpinMag;	// After the first bounce you take this spin mag
var GasPourFeeder	FuelLeak;	// feeder of fuel to leak out after you've bounced once
var Sound  NapalmBounce;
var bool    bExplodeOnContact;	// If you should blow up on the first thing you hit

const START_LEAK_TIME	=	0.25;
const MOVE_UP_DIST		=	800;
const DAMPEN_EXTRA		=	0.25;

// Kamek 5-1
// Count how many people we burn with this one can
var int PeopleBurned;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(FuelLeak != None)
	{
		FuelLeak.GotoState('PouringAndDying');
		/*
		// Check once more to see how many people we burned with the pour feeder
		// And then unlock the achievement
		if (NapalmPourFeeder(FuelLeak) != None)
		{
			PeopleBurned += NapalmPourFeeder(FuelLeak).PeopleBurned;
			//debuglog(self@"destroyed, total people burned"@PeopleBurned);
			
			if (PeopleBurned >= 5
				&& Pawn(Owner).Controller != None
				&& PlayerController(Pawn(Owner).Controller) != None)
				PlayerController(Pawn(Owner).Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Pawn(Owner).Controller),'GoodMorningVietnam');
		}
		*/

		FuelLeak=None;
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Send it with a certain speed and arm it
///////////////////////////////////////////////////////////////////////////////
function SetupShot(bool bExplodeOnHit, bool bStartLeakAfterLaunch)
{
	if ( Role == ROLE_Authority )
	{
		Velocity = GetThrownVelocity(Instigator, Rotation, 0.4);
		RandSpin(StartSpinMag);
	}
	
	bExplodeOnContact = bExplodeOnHit;

	if(bStartLeakAfterLaunch)
		SetTimer(START_LEAK_TIME, false);
}

///////////////////////////////////////////////////////////////////////////////
// Start the fuel leak after this time.
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	StartFuelLeak();
}

///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	Health-=Dam;
	if(Health <= 0)
	{
		GenExplosion(HitLocation, vect(0, 0, 1), None);
		return;
	}

	// Now add in momentum if we didn't explode
	Velocity+=(Momentum/Mass);
}

///////////////////////////////////////////////////////////////////////////////
// Make it start leaking
///////////////////////////////////////////////////////////////////////////////
function StartFuelLeak()
{
	if(FuelLeak == None)
	{
		FuelLeak =  spawn(class'NapalmPourFeeder',Instigator,,Location);
		FuelLeak.MyOwner = Instigator;
		FuelLeak.SetBase(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
function BounceOffSomething( vector HitNormal, actor Wall )
{
	local vector newhit, newnormal, EndPt;
	local bool bStopped;
	local float speed;
	
	if(bBounce == true)
	{
		if(bExplodeOnContact)
		{
			GenExplosion(Location, HitNormal, Wall);
			return;
		}
		else
		{
			speed = VSize(Velocity);
			// Check for a slowed z
			if(speed < MinSpeedForBounce)
			{
				// Check for possible stop by seeing if we're stopped in z and
				// on the ground.
				EndPt = Location;
				EndPt.z-=DIST_CHECK_BELOW;
				// If there is a hit below (ground) then you are stopped.
				if(Trace(newhit, newnormal, EndPt, Location, false) != None)
					bStopped=true;
			}
			// If we've stopped, Explode
			if(bStopped)
			{
				GenExplosion(Location, HitNormal, Wall);
				return;
			}
			else	// do bouncing
			{
				BounceCount++;
				// Start before the recoil so you effect the recoil itself
				if(BounceCount == 1)
					StartSpinMag = FirstBounceSpinMag;

				BounceCrazy(HitNormal, Wall);

				// if it's the first bounce, start leaking napalm
				// Start after the recoil so you get the new rotation
				if(BounceCount == 1)
				{
					StartFuelLeak();
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bounce very irractically
///////////////////////////////////////////////////////////////////////////////
function BounceCrazy(vector HitNormal, Actor HitActor)
{
	local float velcheck;
	local vector vnorm;
	local float crazydir;

	// Crazily bounce it based on the normal and the cross from the velocity and the normal,
	// so sometimes it bounces harshly left and right
	vnorm = Normal(Velocity);
	velcheck = VSize(Velocity);

	// Don't bounce crazily when you hit a person (only bounce left or right or your original velocity)
	if(Pawn(HitActor) != None)
	{
		Velocity = VelDampen*VSize(Velocity)*(Normal(Velocity) Cross vect(0, 0, 1));
		if(FRand() < 0.5)
			Velocity = -Velocity;	// go right, instead of left, 50% of the time
	}
	else // do bounce crazy when you hit anything else
	{
		crazydir = Frand() - 0.5;
		
		if(crazydir > 0.1)
			crazydir = 0.5;
		else if(crazydir < -0.1)
			crazydir = -0.5;


		Velocity = VelDampen * velcheck * ( crazydir*(vnorm Cross HitNormal) + vnorm - 2 * HitNormal * (vnorm Dot HitNormal));
	}

	// Toggle the dampening effects around 1.0, greater and lesser than, each hit
	if(VelDampen < 1.0)
		VelDampen = default.VelDampen + 2*DAMPEN_EXTRA;
	else
		VelDampen = default.VelDampen - DAMPEN_EXTRA;

	// Spin it using a random direction
	StartSpinMag = RotDampen*StartSpinMag;
	RandSpin(StartSpinMag);

	// Play a noise
	PlaySound(NapalmBounce);
}

///////////////////////////////////////////////////////////////////////////////
// Bounce very irractically
///////////////////////////////////////////////////////////////////////////////
function BounceRecoil(vector HitNormal)
{
	BounceCrazy(HitNormal, None);
}

///////////////////////////////////////////////////////////////////////////////
// Bounce off walls.. people.. all the same
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local vector HitNormal;

	if(Other != Instigator)
	{
		// Don't bounce off windows, go right through them, and break them
		if(Window(Other) != None)
			Other.Bump(self);
		else
		{
			HitNormal = -Normal(Velocity);

			BounceOffSomething(HitNormal, Other);

			/*
			// Kamek 5-1
			if (P2Pawn(Other) != None
				&& P2Pawn(Other).Health > 0)
				PeopleBurned++;
			*/

				// after bouncing off it, hurt the thing we hit
			Other.TakeDamage(Damage, Instigator, HitLocation, -MomentumTransfer*HitNormal, MyDamageType);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	BounceOffSomething(HitNormal, Wall);
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local NapalmExplosion nexp;
	local vector endpt;

	// Check to grab the feeder, and set it's next trail on fire autmatically
	if(FuelLeak != None
		&& FuelLeak.Next != None)
	{
		//log(FuelLeak$" has next as "$FuelLeak.Next$" and prev as "$FuelLeak.Prev);
		// Light it's next on fire automatically
		FuelLeak.Next.bCanBeDamaged=true;
		FuelLeak.Next.SetAblaze(HitLocation, true);
	}

	nexp = spawn(class'NapalmExplosion',,,HitLocation);
	/*
	// Kamek 6-19 transfer our number of people burned to the explosion
	// and see if the explosion itself burns enough people for the vietnam achievement
	nexp.PeopleBurned += PeopleBurned;
	*/
	
	nexp.UseNormal = HitNormal;
	nexp.ImpactActor = Other;

	if(FuelLeak != None)
	{
		// Move it up, and make it invisible, so it'll keep pouring fluid
		// towards the impact spot
		endpt = FuelLeak.Location;
		endpt.z = endpt.z + (MOVE_UP_DIST*HitNormal.z);
		if(Trace(HitLocation, HitNormal, endpt, Location, false) != None)
			endpt = HitLocation;
		FuelLeak.SetLocation(endpt);
		FuelLeak.GotoState('PouringAndDying');
		FuelLeak=None;
	}

 	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Constantly snap the fuel leak to the projectile
///////////////////////////////////////////////////////////////////////////////
function Tick( float DeltaTime )
{
	local vector dir;

	if(FuelLeak != None)
	{
		// always reset the dir on each bounce
		dir = -vector(Rotation);
		dir.z-=0.3;
		FuelLeak.SetDir(FuelLeak.Location, dir);
	}
}

defaultproperties
{
	Speed=1200.000000
	MaxSpeed=3000.000000
	Damage=30.000000
	DamageMP=30
	MomentumTransfer=50000.000000
	MyDamageType=class'SmashDamage'
//	SpawnSound=Sound'WarEffects.EightBall.Ignite'
	LifeSpan=100.000000
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.napalmprojectile'
	AmbientGlow=96
	SoundRadius=14.000000
	SoundVolume=255
	SoundPitch=100
	bBounce=true
	bFixedRotationDir=true
	RotationRate=(Yaw=50000)
	ForceType=FT_DragAlong
	ForceRadius=100.000000
	ForceScale=4.000000
	CollisionHeight=15
	CollisionRadius=15
	DetonateTime=5
	MinSpeedForBounce=50
	VelDampen=0.75
	RotDampen=0.95
	StartSpinMag=5000
	FirstBounceSpinMag=80000
	Acceleration=(Z=-800)
	Health=10
	NapalmBounce=Sound'WeaponSounds.napalm_bounce'
}

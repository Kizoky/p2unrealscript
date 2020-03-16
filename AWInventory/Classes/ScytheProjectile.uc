///////////////////////////////////////////////////////////////////////////////
// ScytheProjectile.
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Flying, spinning Scythe
//
///////////////////////////////////////////////////////////////////////////////
class ScytheProjectile extends P2Projectile;

var byte	BounceCount;		// Times you've bounced, and it's counted
var byte	BounceMax;			// Max times to bounce till you stick. You'll stick on this number bounce
var Sound	WallHitSound;
var Sound	FlyingSound;
var bool	bRecordBounce;		// If this is false, it's too allow it to bounce in a tight area
								// for a while before it counts it. If it's true and it bounces	
								// it'll count against the number of times it can bounce before it sticks.
								// This allows a longer time to stay alive in tight areas.
var class<P2WeaponPickup> PickupClass; // class we make when we hit
var float   ReturnMag;			// Magnitude for the return acceleration
var float   FlyOutTime;			// Seconds during which you fly away from the thrower (unless you hit something)
var class <P2Weapon> WeaponOwnerType; // Type of weapon we're made by
var float   FallAcc;			// Acceleration with which we fall when we finally do
var float   FlyingTime;			// Cumulative time it's been flying before. When it passes SeekThrowerTime, that
								// much is subtractive and the blade readjusts to seek the thrower again
var float   FlyTimeInterval;	// Time spent flying before you reevaulate whether you've flown enough and it's
								// time to return
var int		FlyTimesLeft;		// Number of times you've been through FlyTimeInterval. When it hits 0, you return
								// Time spent flying unless you bounce is FlyTimeInterval*FlyTimesLeft.
var float	FlySoundTime;
var P2Emitter WakeEffect;
var class<P2Emitter> WakeEffectClass; 
var Actor	LastPawnHit;		// Last pawn we've hit
var class<ProjectileAlert> projalertclass;	// class of thing that tells others about you coming their way
var ProjectileAlert projalert;	// thing that tells others about you coming their way
var Sound	ScytheHitBody;
var Sound ScytheHitSkel, ScytheHitBot;
var bool	bNoPickup;			// Don't make pickups that bog the framerate when cheats are on

const WAIT_THROWER_TOUCH	=	0.2;	// wait this long to be touched by the Thrower and picked up again
const FLOOR_Z				=	0.5;
const BOUNCE_WALL_DOT		=	0.4;

///////////////////////////////////////////////////////////////////////////////
// Attach the blurry effect
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local int usetemp;
	Super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer)
	{
		if(Level.Game == None
			|| !Level.Game.bIsSinglePlayer)
			WakeEffect = spawn(WakeEffectClass,self);
		else
			// Send player as owner so it will keep up in slomo time
			WakeEffect = spawn(WakeEffectClass,Instigator);
	}

	if(WakeEffect != None)
		WakeEffect.SetBase(self);
	// Setup speed/orientation/timer
	Velocity = GetThrownVelocity(Instigator, Rotation, 0.4);

	UpdateRotation();

	RotationRate.Yaw = StartSpinMag;

	// Make alerter to tell others your flying through the air
	if(projalertclass != None)
	{
		projalert = spawn(projalertclass, self);
		projalert.SetBase(self);
	}

	// If a cheat is used, don't make a pickup
	if(Instigator != None
		&& ScytheWeapon(Instigator.Weapon) != None
		&& ScytheWeapon(Instigator.Weapon).bReaper)
		bNoPickup=true;
}

///////////////////////////////////////////////////////////////////////////////
// Remove blurry effect
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if(WakeEffect != None)
	{
		WakeEffect.Destroy();
		WakeEffect = None;
	}
	if(projalert != None)
	{
		projalert.SetBase(None);
		projalert.Destroy();
		projalert = None;
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Recalc the rotation from the velocity
///////////////////////////////////////////////////////////////////////////////
simulated function UpdateRotation()
{
	local vector vel;
	local vector norm;
	local vector rot;

	SetRotation(Rotator(-Velocity));
}
///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	local float impulse;
	local SparkHit spark1;
	local vector norm;

	// kicking or shoveling begins the path anew
	if(ClassIsChildOf(damageType, class'BludgeonDamage'))
	{
		SetPhysics(PHYS_Projectile);
		// Make sure it can move
		bBounce=true;

		// Throw off some sparks from the hit
		spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(Hitlocation - location));
		// make a ricochet noise
		spark1.PlaySound(WallHitSound,,,,,GetRandPitch());

		// Start path over again--it's like it just got thrown for hte first time
		Velocity = GetThrownVelocity(Instigator, Instigator.GetViewRotation(), 0.4);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function MakePickup()
{
	local P2WeaponPickup newmac;
	local vector usemom;

	if(!bNoPickup)
	{
		newmac = spawn(PickupClass, Owner,,Location);
		// Turn into a pickup in that orientation
		if(newmac != None)
		{
			newmac.bRecordAfterPickup=false;
			// Throw it up into the air from the hit
			usemom = Velocity/2;
			usemom.z+=FRand()*800;
			usemom = 100*usemom;
			newmac.TakeDamage(1,Instigator,Location,usemom,class'damageType');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PerformBounce(vector HitNormal)
{
	local SparkHit spark1;

	Velocity = Velocity - 2 * HitNormal * (Velocity Dot HitNormal);
	// Face the direction you're moving
	UpdateRotation();

	if(Role == ROLE_Authority)
	{
		// Throw off some sparks from the hit
		spark1 = spawn(class'Fx.SparkHitScissors',Owner,,Location,rotator(HitNormal));
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ClearLastHit()
{
	LastPawnHit = None;
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	local rotator userot;
	local SparkHit spark1;
	local SmokeHitPuffMelee smoke1;
	local ScissorsPickup sp;
	local bool bDoBounce;
	local vector mydir;
	local float hitdot;

	mydir = Normal(Velocity);
	hitdot = mydir dot HitNormal;
	// Die on doors, so they don't get stuck as much (only in MP games)
	if((Level.Game == None
			|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		&& DoorMover(Wall) != None)
	{
		if(Role == ROLE_Authority)
		{
			// Throw off some sparks from the stick
			spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(HitNormal));
			
			spark1.PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());
		}
		MakePickup();
		Destroy();
	}
	else
	{
		// Hit hits a floor obliquely, then ricochet off and keep flying, otherwise, fall to ground
//		if(abs(HitNormal.z) < FLOOR_Z
//			&& abs(hitdot) < BOUNCE_WALL_DOT)
//			PerformBounce(HitNormal);
//		else
//		{
			if(Role == ROLE_Authority)
			{
				MakePickup();

				// Throw off some sparks from the stick
				spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(HitNormal));
				
				spark1.PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());

				smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',Owner,,Location,rotator(HitNormal));
			}
			else
				PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());

			// Destroy ourselves after we hit something, whether we made a pickup or not
			Destroy();
//		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Doesn't hurt anyone related to us, or ourselves, but will hurt others.
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local name attachb;
	local AnimNotifyActor sp;
	local coords checkcoords;
	local P2Pawn hitpawn;
	local Rotator rot;
	local byte BlockedHit;
	local SparkHit spark1;
	local SmokeHitPuffMelee smoke1;
	local byte StateChange;

	if ( !RelatedToMe(Pawn(Other)) )
	{
		// AW dogs have special powers. Check to see if they hit it and want to do anything special with it
		if(DogPawn(Other) != None)
		{
			DogPawn(Other).CheckCatchProjectile(self, PickupClass, StateChange);
			// The dog caught it! We're done
			if(StateChange == 1)
			{
				Destroy();
				return;
			}
		}
		// If the dog didn't catch us, continue onward (and hurt the dog)
		if(StateChange == 0)
		{
			// Don't bounce off windows, break them
			if(Window(Other) != None)
				Other.Bump(self);
			// Don't bounce off things, but do fall afterwards, people, parts, bombs
			else if(PeoplePart(Other) != None
				|| Projectile(Other) != None
				|| Pawn(Other) != None)
			{
				// Make sure we're not hitting the last thing we've already hit, or something
				// owned by the last thing
				if(LastPawnHit == None
					|| (Other != LastPawnHit
						&& Other.Owner != LastPawnHit))
				{
					// Balance damage differently for MP vs SP
					if(Level.NetMode == NM_Standalone)
					{
						// People can possibly block a thrown projectile
						if(PersonPawn(Other) == None)
							BlockedHit=0;
						else 
							PersonPawn(Other).CheckBlockMelee(Location, BlockedHit);

						if(BlockedHit == 0)
						{
							Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
							smoke1 = spawn(class'SmokeHitPuffMelee',Owner,,Location);
							if (P2MocapPawn(Other) != None)
								if (P2MocapPawn(Other).MyRace < RACE_Automaton)
									smoke1.PlaySound(ScytheHitBody,,1.0,false,200.0,GetRandPitch());
								else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
									smoke1.PlaySound(ScytheHitBot,,1.0,false,200.0,GetRandPitch());
								else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
									smoke1.PlaySound(ScytheHitSkel,,1.0,false,200.0,GetRandPitch());
							else
								smoke1.PlaySound(ScytheHitBody,,1.0,false,200.0,GetRandPitch());
						}
						else // ricochet off the guy that is blocking it
						{
							Velocity = -Velocity;
							HitWall(Normal(Other.Location - Location), Level);
						}
					}
					else
					{
						Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
						spark1 = spawn(class'SparkHitProjectile',Owner,,Location);
						if(spark1 != None)
							spark1.PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());
					}
					// Save the last connection
					if(Pawn(Other) != None
						&& Other != Instigator)
						LastPawnHit=Other;
					ReduceFlight(FlyTimesLeft);
				}
			}
			// fall to the ground but hurt most things
			else
			{
				// Balance damage differently for MP vs SP
				if(Level.Game != None
					&& FPSGameInfo(Level.Game).bIsSinglePlayer)
					Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				else
					Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				PlaySound(WallHitSound,,,,1.0);
				// bounce off it
				Velocity = -Velocity/2;
				Velocity.z += FRand()*100;
				// then fall
				MakePickup();
				Destroy();
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Explode(vector HitLocation, vector HitNormal)
{
 	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Go to usual flying state, can't once you've started returning
///////////////////////////////////////////////////////////////////////////////
function ContinueFlying()
{
	GotoState('MovingOut');
}

///////////////////////////////////////////////////////////////////////////////
// True once you get far enough from the thrower
///////////////////////////////////////////////////////////////////////////////
function bool CanTouchThrower()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// You're not flying back right now, but it does reduce your fly time
///////////////////////////////////////////////////////////////////////////////
function ReduceFlight(int Count)
{
	FlyTimesLeft-=Count;
}

///////////////////////////////////////////////////////////////////////////////
// Fall to ground
///////////////////////////////////////////////////////////////////////////////
simulated function StartFalling()
{
	Acceleration.z=FallAcc;
	GotoState('FallingDown');
}

///////////////////////////////////////////////////////////////////////////////
// Play your flying noise
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	PlaySound(FlyingSound,SLOT_None,255,false,60,1.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flying through the air, away from the Thrower
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto simulated state StartFlying
{
Begin:
	Timer();
	SetTimer(FlySoundTime, true);
	Sleep(WAIT_THROWER_TOUCH);
	ContinueFlying();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flying through the air, away from the Thrower
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state MovingOut
{
	///////////////////////////////////////////////////////////////////////////////
	// True once you get far enough from the thrower
	///////////////////////////////////////////////////////////////////////////////
	function bool CanTouchThrower()
	{
		return true;
	}
Begin:
	Sleep(FlyTimeInterval);
	bRecordBounce=true;
	ReduceFlight(1);
	if(FlyTimesLeft <= 0)
		StartFalling();
	else
		Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Still flying, but now falling down
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state FallingDown
{
}

defaultproperties
{
     BounceMax=6
     WallHitSound=Sound'AWSoundFX.Scythe.scythehitwall'
     FlyingSound=Sound'AWSoundFX.Scythe.scythethrowloop'
     bRecordBounce=True
     PickupClass=Class'AWInventory.ScythePickup'
     ReturnMag=800.000000
     FallAcc=-1000.000000
     FlyTimeInterval=0.500000
     FlyTimesLeft=6
     FlySoundTime=0.250000
     WakeEffectClass=Class'AWEffects.ScytheWake'
     projalertclass=Class'AWInventory.ProjectileAlert'
     ScytheHitBody=Sound'AWSoundFX.Scythe.scythelimbhit'
     VelDampen=1.000000
     RotDampen=1.000000
     StartSpinMag=-400000.000000
     DamageMP=70.000000
     speed=800.000000
     MaxSpeed=800.000000
     TossZ=0.000000
     Damage=70.000000
     DamageRadius=0.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'AWEffects.FlyingScytheDamage'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AWWeaponStatic.Weapons.Scythe_1'
     AmbientGlow=64
     CollisionRadius=50.000000
     CollisionHeight=20.000000
     bProjTarget=True
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     ScytheHitBot=Sound'AWSoundFX.Scythe.scythehitwall'
     ScytheHitSkel=Sound'AWSoundFX.Scythe.scythehitwall'
}

///////////////////////////////////////////////////////////////////////////////
// SledgeProjectile.
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Flying, spinning Sledgehammer
//
///////////////////////////////////////////////////////////////////////////////
class SledgeProjectile extends P2Projectile;

var byte	BounceCount;		// Times you've bounced, and it's counted
var byte	BounceMax;			// Max times to bounce till you stick. You'll stick on this number bounce
var Sound	WallHitSound;
var Sound	FlyingSound;
var bool	bRecordBounce;		// If this is false, it's too allow it to bounce in a tight area
								// for a while before it counts it. If it's true and it bounces	
								// it'll count against the number of times it can bounce before it sticks.
								// This allows a longer time to stay alive in tight areas.
var class<P2WeaponPickup> PickupClass; // class we make when we hit
var float   FlyOutTime;			// Seconds during which you fly away from the thrower (unless you hit something)
var float	SeekThrowerTime;		// seconds till we readjust our acceleration and velocity towards the Thrower
var class <P2Weapon> WeaponOwnerType; // Type of weapon we're made by
var float   FallAcc;			// Acceleration with which we fall when we finally do
var float   FlyingTime;			// Cumulative time it's been flying before. When it passes SeekThrowerTime, that
								// much is subtractive and the blade readjusts to seek the thrower again
var float   FlyTimeInterval;	// Time spent flying before you reevaulate whether you've flown enough and it's
								// time to return
var int		FlyTimesLeft;		// Number of times you've been through FlyTimeInterval. When it hits 0, you return
								// Time spent flying unless you bounce is FlyTimeInterval*FlyTimesLeft.
var Sound SledgeHitBody;
var Sound SledgeHitBot;
var Sound SledgeHitSkel;
var float	FlySoundTime;
var SledgeWake WakeEffect;
var class<SledgeWake> WakeEffectClass; 
var class<ProjectileAlert> projalertclass;	// class of thing that tells others about you coming their way
var ProjectileAlert projalert;	// thing that tells others about you coming their way
var bool bMadePickup;			// If we made the pickup we're ready to die. Sometimes you can
								// try to throw the sledge right into someone and it makes it all in PostBeginPlay
								// but then if we destroy it now, the weapon will think we through it invalidly
								// into a wall, and leave you with the sledge even though the pickup was made.
								// We mark it with this in case it happens within the spawn.
var bool	bNoPickup;			// Don't make pickups that bog the framerate when cheats are on
var class<TimedMarker> PawnHitMarkerMade;	// danger made when a pawn is hit by this weapon

const WAIT_THROWER_TOUCH	=	0.2;	// wait this long to be touched by the Thrower and picked up again
const FLOOR_Z				=	0.5;
const BOUNCE_WALL_DOT		=	0.4;
const SIDE_RAND_MAG			=	1.0;

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

	RotationRate.Roll = StartSpinMag;

	// Make alerter to tell others your flying through the air
	if(projalertclass != None)
	{
		projalert = spawn(projalertclass, self);
		projalert.SetBase(self);
	}

	// If a cheat is used, don't make a pickup
	if(Instigator != None
		&& SledgeWeapon(Instigator.Weapon) != None
		&& SledgeWeapon(Instigator.Weapon).bHulkSmash)
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
	local rotator userot;

	SetRotation(Rotator(-Velocity));
	// orient it end over end, flying forward
	userot = Rotation;
	userot.Yaw+=16386;
	SetRotation(userot);
	if(WakeEffect != None)
	{
		// Set up effect to be angled to the side just a little so it's
		// easier to see
		userot.Yaw-=2000;
		vel = vector(userot);
		WakeEffect.ChangeDirection(vel);
	}
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
	local vector usemom, oldmom, newloc;
	local float siderand;

	if(!bNoPickup)
	{
		newmac = spawn(PickupClass, Owner,,Location);
		// If we didn't make a pickup, try shooting it backward some
		if (newmac == None)
		{
			newloc = Normal(Velocity) * 250 + Location;
			newmac = spawn(PickupClass, Owner,, newloc);
			// Try once more if it didn't take.
			if (newmac == None)
			{
				newloc = Normal(Velocity) * 500 + Location;
				newmac = spawn(PickupClass, Owner,, newloc);
			}
		}
		
		// Turn into a pickup in that orientation
		if(newmac != None)
		{
			newmac.bRecordAfterPickup=false;
			// Throw it up into the air from the hit
			usemom = Velocity/2;
			oldmom = usemom;
			// Throw it to the sides sometimes too, to make it harder to pick it up
			siderand = SIDE_RAND_MAG*(Frand());
			if(Rand(2) == 0)
			{
				// throw sort of left
				usemom.x += (siderand*oldmom.y);
				usemom.y += (-siderand*oldmom.x);
			}
			else 
			{
				// throw sort of right
				usemom.x += (-siderand*oldmom.y);
				usemom.y += (siderand*oldmom.x);
			}
			usemom.z+=FRand()*800;
			usemom = 100*usemom;
			newmac.TakeDamage(1,Instigator,Location,usemom,class'damageType');
			bMadePickup=true;
		}
	}
	else
		bMadePickup=true;
}

///////////////////////////////////////////////////////////////////////////////
// Prep me to destroy next.
///////////////////////////////////////////////////////////////////////////////
function SetupForDestroy()
{
	GotoState('DestroyNext');
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
		// If it didn't make a pickup, bounce off
		if (!bMadePickup)
			PerformBounce(HitNormal);
		else
			SetupForDestroy();
	}
	else
	{
		// Hit hits a wall obliquely, then ricochet off and keep flying, otherwise, fall to ground
		if(abs(HitNormal.z) < FLOOR_Z
			&& abs(hitdot) < BOUNCE_WALL_DOT
			&& DoorMover(Wall) == None)
			PerformBounce(HitNormal);
		else
		{
			if(Role == ROLE_Authority)
			{
				MakePickup();
				// If it didn't make a pickup, bounce off
				if (!bMadePickup)
				{
					PerformBounce(HitNormal);
					return;
				}
				// Stop moving 
				Velocity = vect(0,0,0);

				// Throw off some sparks from the stick
				spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(HitNormal));
				
				spark1.PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());

				smoke1 = Spawn(class'SmokeHitPuffMelee',Owner,,Location,rotator(HitNormal));

				if (DoorMover(Wall) != None)
				{
					// Break down the door
					Wall.TakeDamage( Damage, instigator, Location, HitNormal, MyDamageType);
				}
			}
			else
				PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());

			// Destroy ourselves after we hit something, whether we made a pickup or not
			SetupForDestroy();
		}
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

	if (DoorMover(Other) != None)
	{
	}
	if ( !RelatedToMe(Pawn(Other)) )
	{
		// Cows are very special cases, they're heads can explode, or the hammer can get stuck in their butts
		if(CowPawn(Other) != None)
		{
			if(CowPawn(Other).CheckHammerGetsStuckProj(self))
			{
				// We got stuck, get rid of us
				SetupForDestroy();
				return;
				// If not, continue on and hurt the cow in the Else at the bottom
			}
		}

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
			// Blow through and hurt some small things
			else if(PeoplePart(Other) != None
				|| Projectile(Other) != None)
			{
				// Balance damage differently for MP vs SP
				if(Level.NetMode == NM_Standalone)
				{
					Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				}
				else
					Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				PlaySound(WallHitSound,,,,1.0);
			}
			// fall to the ground but hurt most things
			else
			{
				// Balance damage differently for MP vs SP
				if(Level.Game != None
					&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				{
					// People can possibly block a thrown projectile
					if(PersonPawn(Other) == None)
						BlockedHit=0;
					else 
						PersonPawn(Other).CheckBlockMelee(Location, BlockedHit);

					if(BlockedHit == 0)
					{
						// This is if a pawn is hit by a bullet (or hurt bad), so it's really scary
						if(Other != None
							&& PawnHitMarkerMade != None)
						{
							//log("Notifying pawns of hit"@Other@PawnHitMarkerMade);
							PawnHitMarkerMade.static.NotifyControllersStatic(
								Level,
								PawnHitMarkerMade,
								FPSPawn(Instigator), 
								FPSPawn(Instigator), // We want the creator to be instigator also
								// because this is much more like a gunfire sort of thing, rather than a pawn hit by
								// a bullet
								PawnHitMarkerMade.default.CollisionRadius,
								Other.Location);
						}
						Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
						smoke1 = spawn(class'SmokeHitPuffMelee',Owner,,Location);
						if (P2MocapPawn(Other) != None)
							if (P2MocapPawn(Other).MyRace < RACE_Automaton)
								smoke1.PlaySound(SledgeHitBody,,1.0,false,200.0,GetRandPitch());
							else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
								smoke1.PlaySound(SledgeHitBot,,1.0,false,200.0,GetRandPitch());
							else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
								smoke1.PlaySound(SledgeHitSkel,,1.0,false,200.0,GetRandPitch());
						else
							smoke1.PlaySound(SledgeHitBody,,1.0,false,200.0,GetRandPitch());
					}
					else // ricochet off the guy that is blocking it
					{
						if (DoorMover(Other) != None)
						{
							// Break down the door
							Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
							spark1 = spawn(class'SparkHitProjectile',Owner,,Location);
							if(spark1 != None)
								spark1.PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());
						}
						else
						{
							Velocity = -Velocity;
							HitWall(Normal(Other.Location - Location), Level);
						}
					}
				}
				else
				{
					Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
					spark1 = spawn(class'SparkHitProjectile',Owner,,Location);
					if(spark1 != None)
						spark1.PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());
				}
				// bounce off it
				Velocity = -Velocity/2;
				Velocity.z += FRand()*100;
				// then fall
				MakePickup();
				// If it didn't make a pickup, bounce off
				if (!bMadePickup)
					PerformBounce(Normal(Velocity));
				else
					SetupForDestroy();
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Explode(vector HitLocation, vector HitNormal)
{
	SetupForDestroy();
}

///////////////////////////////////////////////////////////////////////////////
// Go to usual flying state
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
	PlaySound(FlyingSound,SLOT_None,255,false,60,0.7);
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
	{
		StartFalling();
	}
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Will be destroyed on next entry to script, no matter what
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DestroyNext
{
	ignores ProcessTouch, HitWall, Explode, MakePickup;
Begin:
	Sleep(0.0);
	Destroy();
}

defaultproperties
{
     BounceMax=6
     WallHitSound=Sound'AWSoundFX.Sledge.hammerhitwall_metalhit'
     FlyingSound=Sound'AWSoundFX.Sledge.hammerthrowloop'
     bRecordBounce=True
     PickupClass=Class'AWInventory.SledgePickup'
     FallAcc=-1000.000000
     FlyTimeInterval=0.500000
     FlyTimesLeft=6
     SledgeHitBody=Sound'AWSoundFX.Sledge.hammersmashbody'
     SledgeHitBot=Sound'AWSoundFX.Sledge.hammerhitwall_metalhit'
     SledgeHitSkel=Sound'AWSoundFX.Sledge.hammerhitwall_metalhit'
     FlySoundTime=0.250000
     WakeEffectClass=Class'AWEffects.SledgeWake'
     projalertclass=Class'AWInventory.ProjectileAlert'
     VelDampen=1.000000
     RotDampen=1.000000
     StartSpinMag=-400000.000000
     DamageMP=100.000000
     speed=1200.000000
     MaxSpeed=1200.000000
     TossZ=0.000000
     Damage=100.000000
     DamageRadius=0.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'FlyingSledgeDamage'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AWWeaponStatic.Weapons.Sledge_throw'
     AmbientGlow=64
     CollisionRadius=15.000000
     CollisionHeight=40.000000
     bProjTarget=True
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     PawnHitMarkerMade=Class'Postal2Game.PawnBeatenMarker'
}

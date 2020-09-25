///////////////////////////////////////////////////////////////////////////////
// MacheteProjectile.
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Flying, spinning machete
//
///////////////////////////////////////////////////////////////////////////////
class MacheteProjectile extends P2Projectile;

var byte	BounceCount;		// Times you've bounced, and it's counted
var byte	BounceMax;			// Max times to bounce till you stick. You'll stick on this number bounce
var Sound	WallHitSound;
var Sound	FlyingSound;
//var bool	bRecordBounce;		// If this is false, it's to allow it to bounce in a tight area
								// for a while before it counts it. If it's true and it bounces	
								// it'll count against the number of times it can bounce before it sticks.
								// This allows a longer time to stay alive in tight areas.
var class<P2WeaponPickup> PickupClass; // class we make when we hit
var float   ReturnMag;			// Magnitude for the return acceleration
var float   FlyOutTime;			// Seconds during which you fly away from the thrower (unless you hit something)
var float	SeekThrowerTime;		// seconds till we readjust our acceleration and velocity towards the Thrower
var class <P2Weapon> WeaponOwnerType; // Type of weapon we're made by
var float   FlyingTime;			// Cumulative time it's been flying before. When it passes SeekThrowerTime, that
								// much is subtractive and the blade readjusts to seek the thrower again
var float   FlyTimeInterval;	// Time spent flying before you reevaulate whether you've flown enough and it's
								// time to return
var int		FlyTimesLeft;		// Number of times you've been through FlyTimeInterval. When it hits 0, you return
								// Time spent flying unless you bounce is FlyTimeInterval*FlyTimesLeft.
var float	FlySoundTime;
var P2Emitter WakeEffect;
var class<P2Emitter> WakeEffectClass; 
var float   ReturnRatio;		// How sharply we're trying to get back to the player
var float   ReturnRatioMax;
var Actor	LastPawnHit;		// Last pawn we've hit
var class<ProjectileAlert> projalertclass;	// class of thing that tells others about you coming their way
var ProjectileAlert projalert;	// thing that tells others about you coming their way
var Sound MacheteHitBody;
var Sound MacheteHitBot;
var Sound MacheteHitSkel;

const WAIT_THROWER_TOUCH	=	0.2;	// wait this long to be touched by the Thrower and picked up again
const FLOOR_Z				=	0.5;

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
		BeginFlyingAgain();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function MakePickup()
{
	local P2WeaponPickup newmac;
	local vector usemom;

	newmac = spawn(PickupClass, Owner,,Location);
	// Turn into a pickup in that orientation
	if(newmac != None)
	{
		newmac.bRecordAfterPickup=false;
		// Throw it up into the air from the hit
		usemom = Velocity;
		usemom.z+=FRand()*500;
		usemom = 100*usemom;
		newmac.bAllowMovement = true; // Change by NickP: MP fix
		newmac.TakeDamage(1,Instigator,Location,usemom,class'damageType');
		// Tell the instigator if they're waiting on us, to change to
		// another weapon becuase we're not coming back
		//log(Self$" inst "$instigator$" weap "$instigator.Weapon$" state "$instigator.weapon.getstatename());
		if(Instigator != None
			&& P2Player(Instigator.Controller) != None
			&& MacheteWeapon(Instigator.Weapon) != None
			&& Instigator.Weapon.IsInState('WaitingOnBlade'))
			P2Player(Instigator.Controller).NextWeapon();
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
	local SmokeHitPuffGeneric smoke1;
	local ScissorsPickup sp;
	local bool bDoBounce;

	//log(Self$" hit wall "$hitnormal);
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
	else if(bBounce == true)
	{
		// On hard connections, clear the last pawn we hit
		// Because now it could bounce back and him again
		ClearLastHit();

		// If we hit the floor or ceiling, just return sooner, but not immediately
		if(HitNormal.z > FLOOR_Z
			|| HitNormal.z < -FLOOR_Z)
			HitFloor();
		else
			// If you hit a wall, return to the Thrower now (ignores it if you already are returning)
			StartReturn();

//		if(bRecordBounce)
//		{
			BounceCount++;
			//bRecordBounce=false;
//		}

		// If they've bounced enough, fall down
		if(BounceCount >= BounceMax)
		{
			if(Role == ROLE_Authority)
			{
				// Only make them turn into single pickups 
				// in single player mode
				//if(FPSGameInfo(Level.Game).bIsSinglePlayer)
				//{
					MakePickup();
				//}

				// Throw off some sparks from the stick
				spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(HitNormal));
				
				spark1.PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());

				smoke1 = Spawn(class'Fx.SmokeHitPuffGeneric',Owner,,Location,rotator(HitNormal));
			}
			else
				PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());

			// Destroy ourselves after we hit something, whether we made a pickup or not
			Destroy();
		}
		else
			bDoBounce=true;

		if(bDoBounce)
			// if not, then make them bounce without losing any energy
			PerformBounce(HitNormal);
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

	if(!bDeleteMe)
	{
		if(CanTouchThrower()
			&& Other == Instigator)
		{
			TouchThrower();
		}
		else if ( !RelatedToMe(Pawn(Other)) )
		{
			// AW dogs have special powers. Check to see if they hit it and want to do anything special with it
			if(DogPawn(Other) != None)
			{
				DogPawn(Other).CheckCatchProjectile(self, PickupClass, StateChange);
				// The dog caught it! We're done
				if(StateChange == 1)
				{
					// Tell the instigator if they're waiting on us, to change to
					// another weapon because we're not coming back--we just got caught in the dog's mouth!
					if(Instigator != None
						&& P2Player(Instigator.Controller) != None
						&& MacheteWeapon(Instigator.Weapon) != None
						&& Instigator.Weapon.IsInState('WaitingOnBlade'))
						P2Player(Instigator.Controller).NextWeapon();
					Destroy();
					return;
				}
			}
			if(StateChange == 0)
			{
				// Don't bounce off windows, break them
				if(Window(Other) != None)
					Other.Bump(self);
				else if((Pawn(Other) != None
						|| PeoplePart(Other) != None)
					&& bBounce)
				{
					// Make sure we're not hitting the last thing we've already hit, or something
					// owned by the last thing
					if(LastPawnHit == None
						|| (Other != LastPawnHit
							&& Other.Owner != LastPawnHit))
					{
						// Balance damage differently for MP vs SP
						// Change by NickP: MP fix
						//if(Level.NetMode == NM_Standalone)
						if(Level.Game != None
							&& FPSGameInfo(Level.Game).bIsSinglePlayer)
						// End
						{
							//log(self$" check to hit "$Other);
							// People can possibly block a thrown projectile
							if(PersonPawn(Other) == None)
								BlockedHit=0;
							else 
								PersonPawn(Other).CheckBlockMelee(Location, BlockedHit);

							if(BlockedHit == 0)
							{
								Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
								smoke1 = spawn(class'SmokeHitPuffMelee',Owner,,Location);
								if(smoke1 != None)
								{
									if (P2MocapPawn(Other) != None)
										if (P2MocapPawn(Other).MyRace < RACE_Automaton)
											smoke1.PlaySound(MacheteHitBody,,1.0,false,200.0,GetRandPitch());
										else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
											smoke1.PlaySound(MacheteHitBot,,1.0,false,200.0,GetRandPitch());
										else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
											smoke1.PlaySound(MacheteHitSkel,,1.0,false,200.0,GetRandPitch());
									else
										smoke1.PlaySound(MacheteHitBody,,1.0,false,200.0,GetRandPitch());
								}
							}
							else
								HitWall(Normal(Other.Location - Location), Level);
						}
						else
						{
							Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
							spark1 = spawn(class'SparkHitProjectile',Owner,,Location);
							if(spark1 != None)
								spark1.PlaySound(WallHitSound,,1.0,false,200.0,GetRandPitch());
						}
					}

					// Save the last connection
					if(Pawn(Other) != None
						&& Other != Instigator)
						LastPawnHit=Other;
				}
				// bounce off other stuff if you can
				else //if(BounceCount < BounceMax)
				{
					PlaySound(WallHitSound,,,,1.0);
					PerformBounce(Location - HitLocation);
					// only hurt things if you're moving
					if(bBounce)
					{
						// Balance damage differently for MP vs SP
						if(Level.Game != None
							&& FPSGameInfo(Level.Game).bIsSinglePlayer)
							Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
						else
							Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
					}
					StartReturn();
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Give the blade back the thrower (he caught it in mid-air--yeah right)
///////////////////////////////////////////////////////////////////////////////
function TouchThrower()
{
	local P2WeaponPickup mpick;
	local bool bGaveBack;
	local MacheteWeapon machweap;

	machweap = MacheteWeapon(Instigator.Weapon);
	if(machweap != None)
	{
		bGaveBack = machweap.GiveBackBlade();
		if(bGaveBack)
			// caught it, so delete our flying version
			Destroy();
	}

	if(!bGaveBack) // Make a pickup inside the player and hope he touches it
	{
		// Quickly make a pickup inside the player, then try to get the player
		// to touch it.. then remove them both, if he does.
		mpick = spawn(PickupClass,,,Instigator.Location);
		if(mpick != None)
		{
			mpick.RespawnTime=0.0; // Don't allow this to respawn
			mpick.GotoState('Pickup');
			mpick.Touch(Instigator);
			mpick.Destroy();
			// Conditional destroy if we're a single player game--it gets better
			// service. A server/client game will always destroy the projectile.
			if(mpick == None
				|| mpick.bDeleteMe
				|| Level.NetMode == NM_DedicatedServer)
				Destroy();
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
// Start flying all over again, if you're returning, because the dude kicked
// you
///////////////////////////////////////////////////////////////////////////////
function BeginFlyingAgain()
{
	ClearLastHit();
	ReturnRatio = default.ReturnRatio;
	Acceleration = vect(0,0,0);
	BounceCount=0;
	FlyTimesLeft = default.FlyTimesLeft;
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
// Switch from flying forward to trying to home back in on the Thrower, to be
// picked up again.
///////////////////////////////////////////////////////////////////////////////
function StartReturn()
{
	ClearLastHit();
	GotoState('Returning');
}

///////////////////////////////////////////////////////////////////////////////
// You're not flying back right now, but it does reduce your fly time
///////////////////////////////////////////////////////////////////////////////
function ReduceFlight(int Count)
{
	FlyTimesLeft-=Count;
}

///////////////////////////////////////////////////////////////////////////////
// While flying we hit a floor, so we'll fly just a little farther and turn around
///////////////////////////////////////////////////////////////////////////////
function HitFloor()
{
	if(FlyTimesLeft > 1)
		FlyTimesLeft = 1;
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
//	bRecordBounce=true;
	ReduceFlight(1);
	if(FlyTimesLeft <= 0)
		// You've flew forward enough, now return to the Thrower
		StartReturn();
	else
		Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Homing back in on the Thrower
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state Returning
{
	ignores StartReturn, ContinueFlying;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local vector toThrower;
		local float vmag;

		toThrower = Instigator.Location + Instigator.EyePosition()/2 - Location;

		// Don't rely on Touch to decide if the player grabbed us, it's way too
		// spotty
		if(VSize(toThrower) < 1.5*CollisionRadius)
			TouchThrower();
		else // check to change velocity again
		{
			toThrower = Normal(toThrower);
			FlyingTime+=DeltaTime;
			if(FlyingTime > SeekThrowerTime)
			{
				vmag = Vsize(Velocity);
				Acceleration = ReturnMag*toThrower;
				Velocity = (1.0-ReturnRatio)*Velocity + (ReturnRatio)*vmag*toThrower; 
				FlyingTime -= SeekThrowerTime;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// True once you get far enough from the thrower
	///////////////////////////////////////////////////////////////////////////////
	function bool CanTouchThrower()
	{
		return true;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Seek the thrower
	///////////////////////////////////////////////////////////////////////////////
	function AdjustSeek()
	{
		local vector toThrower;
		local float vmag;

		toThrower = Normal(Instigator.Location + Instigator.EyePosition()/2 - Location);
		vmag = Vsize(Velocity);
		Acceleration = ReturnMag*toThrower;
		Velocity = Velocity/2 + vmag*toThrower/2; 
	}
Begin:
	// Reset the flying times, so we can shift the ReturnRatio. At first, 
	// the blade takes a little while to get back to the player, but after a short
	// time it curls more harshly to get to him
	Sleep(3*FlyTimeInterval);
	ReturnRatio+=0.1;
	if(ReturnRatio < ReturnRatioMax)
		Goto('Begin');
	else
		ReturnRatio=ReturnRatioMax;
}

defaultproperties
{
	// Change by NickP: MP fix
	bNetTemporary=false
	bReplicateMovement=true
	bUpdateSimulatedPosition=true
	// End

     BounceMax=12
     WallHitSound=Sound'AWSoundFX.Machete.machetehitwall'
     FlyingSound=Sound'AWSoundFX.Machete.machetethrowloop'
     PickupClass=Class'AWInventory.MachetePickup'
     ReturnMag=800.000000
     SeekThrowerTime=0.400000
     FlyTimeInterval=0.500000
     FlyTimesLeft=6
     FlySoundTime=0.250000
     WakeEffectClass=Class'AWEffects.MacheteWake'
     ReturnRatio=0.400000
     ReturnRatioMax=0.900000
     projalertclass=Class'AWInventory.ProjectileAlert'
     MacheteHitBody=Sound'AWSoundFX.Machete.machetelimbhit'
     VelDampen=1.000000
     RotDampen=1.000000
     StartSpinMag=-400000.000000
     DamageMP=100.000000
     speed=800.000000
     MaxSpeed=800.000000
     TossZ=0.000000
     Damage=50.000000
     DamageRadius=0.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'AWEffects.FlyingMacheteDamage'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AWWeaponStatic.Weapons.Machete_1'
     AmbientGlow=64
     CollisionRadius=50.000000
     CollisionHeight=20.000000
     bProjTarget=True
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     machetehitbot=Sound'AWSoundFX.Machete.machetehitwall'
     machetehitskel=Sound'AWSoundFX.Machete.machetehitwall'
}

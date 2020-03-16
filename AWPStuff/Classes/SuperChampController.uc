///////////////////////////////////////////////////////////////////////////////
// SuperChampController
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Invincible version of Champ that follows the player around and protects him
///////////////////////////////////////////////////////////////////////////////
class SuperChampController extends AWDogController;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var int AttackerHitCount;							// Number of times we've hit our current attacker. After so many times we'll upgrade our damage to machete damage and slice off limbs
var() int NumHitsToUpgradeDamage;					// Number of hits until we upgrade damage
var() class<DamageType> UpgradedAttackDamageType;	// Damage class of upgraded attack
var() class<DamageType> ShredDeadDamageType;		// Damage class caused by shred dead attack
var float RunToHeroTime;							// Amount of time we've spent running to our hero. If it gets too high we'll teleport to him
var float RunToHeroMax;								// Max amount of time we'll run to the hero before attempting a teleport

const RETREAT_DIST	   = 150;

///////////////////////////////////////////////////////////////////////////////
// Local spot to set my attacker, only assigns old when not none.
///////////////////////////////////////////////////////////////////////////////
function SetAttacker(FPSPawn NewAttacker)
{
	// Reset our bone-grind count	
	if (NewAttacker != Attacker)
		AttackerHitCount=0;
		
	Super.SetAttacker(NewAttacker);
}

///////////////////////////////////////////////////////////////////////////
// When attacked
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;
	local vector HitNormal, HitLocation, dest;
	local Actor HitActor;
	local FPSPawn OldAttacker;

	if(Damage > 0)
	{
		// If a cat attacks us, freak out no matter what
		if(AWCatPawn(Other) != None)
		{
			// Try to get 'em off
			SetAttacker(FPSPawn(Other));
			GotoState('ShredAttack');
		}
		if ( (FPSPawn(Other) != None) && (Other != Pawn))
		{
			if(Other == Hero)
			{
				// Play a got hurt noise, no matter what
				MyPawn.PlayHurtSound();
				if (!IsInState('LimpByHero'))
					GotoState('LimpByHero');
			}
			else if(Frand() < WHIMPER_AND_RUN_FREQ)
			{
				SetAttacker(FPSPawn(Other));

				dest = VRand();
				dest.z=0;
				dest = (RETREAT_DIST + FRand()*RETREAT_DIST)*dest + MyPawn.Location;

				HitActor = Trace(HitLocation, HitNormal, dest, MyPawn.Location, true);

				// Move away from obstruction
				if(HitActor != None)
				{
					MovePointFromWall(HitLocation, HitNormal, MyPawn);
				}
				else // set up hit location to raise from ground
					HitLocation = dest;
				
				// Make sure it's not floating in space
				RaisePointFromGround(HitLocation, MyPawn);
				dest = HitLocation;

				// Run to a point just behind me
				SetEndPoint(dest, DEFAULT_END_RADIUS);
				// Run away first, then get mad and attack
				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				SetNextState('AttackTarget');
				GotoStateSave('RunningScared');
			}
			else 
			{
				// Play a got hurt noise, no matter what
				MyPawn.PlayHurtSound();

				OldAttacker = Attacker;

				SetAttacker(FPSPawn(Other));

				if(OldAttacker == None
					|| OldAttacker != Attacker)
				{
					StartAttacking();
				}
			}
		}
		else	// hit by something like a cactus
		{
			dest = VRand();
			dest.z=0;
			dest = (RETREAT_DIST + FRand()*RETREAT_DIST)*dest + MyPawn.Location;

			HitActor = Trace(HitLocation, HitNormal, dest, MyPawn.Location, true);

			// Move away from obstruction
			if(HitActor != None)
			{
				MovePointFromWall(HitLocation, HitNormal, MyPawn);
			}
			else // set up hit location to raise from ground
				HitLocation = dest;
			
			// Make sure it's not floating in space
			RaisePointFromGround(HitLocation, MyPawn);
			dest = HitLocation;

			// Run to a point just behind me
			SetEndPoint(dest, DEFAULT_END_RADIUS);
			// Run away first, then get mad and attack
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('AttackTarget');
			GotoStateSave('RunningScared');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set our new hero
///////////////////////////////////////////////////////////////////////////////
function HookHero(FPSPawn NewHero, optional out byte Worked)
{
	local float diffoffset;
	
	if(NewHero != Hero)
	{
		Super(AnimalController).HookHero(NewHero);

		if(NewHero == Hero)
		{
			// If we have a hero, don't let us be travelled between levels (if
			// our hero is the player, he'll specifically travel us himself)
			MyPawn.bCanTeleportWithPlayer=false;

			// Automatically set full love
			ChangeHeroLove(HERO_LOVE_MAX, 0);

			// Don't let dogs be removed for movies
			MyPawn.bKeepForMovie=true;
			
			Worked=1;
		}
	}

	ProspectiveHero = None;
}

///////////////////////////////////////////////////////////////////////////////
// A segment of hero love time has ended, check about changing our perception
// around the hero
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	// Champ always loves the player, don't let hero love decay.
	ChangeHeroLove(0, HERO_LOVE_SUB_TIME);

	// Check to take a crap
	CheckToTakeCrap();
}

///////////////////////////////////////////////////////////////////////////////
// We're either hopelessly stuck in some corner of the map, or the player has
// managed to run so far ahead, either with cheats or with speedrunning
// techniques, that we can't possibly catch up. Find a safe place the player
// isn't looking and warp them there.
///////////////////////////////////////////////////////////////////////////////
function TryToTeleportToHero()
{
	local NavigationPoint N;
	local float dist;
	local bool bSuccess;
	
	// Sanity check.
	if (Hero == None)
		return;
		
	// Find a navigation point close to the dude
	for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
	{
		// Only use pathnodes, don't try to use ladders or doors or shit like that
		if (PathNode(N) != None)
		{
			dist = VSize(N.Location - Hero.Location);
			// Pick a spot that's within the hero radius, that can't be seen by the player, and has a line-of-sight to the hero (so we can catch back up quickly)
			if (dist <= HERO_END_RADIUS * 2 && !N.PlayerCanSeeMe() && FastTrace(N.Location, Hero.Location))
			{
				// Try to move there
				Pawn.SetLocation(N.Location);
				if (Pawn.Location == N.Location)
					bSuccess = true;
			}
		}
		
		// We're done! Get out
		if (bSuccess)
		{
			GotoState('RunToHero');
			break;
		}
	}
	
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Jump on this guy and hurt him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PounceOnTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		local FPSPawn otherpawn;
		local vector hitpos, dir;

		otherpawn = FPSPawn(Other);

		if(otherpawn != None
			&& otherpawn.Health > 0
			&& otherpawn == Attacker
			&& !bHurtTarget)
		{
			bHurtTarget=true;
			GiveUpCount = 0;	// Reset our give-up count if we successfully hurt something.
			AttackerHitCount++;
			
			// give it an extra boost
			dir = Normal(Other.Location - MyPawn.Location) + VRand();
			hitpos = Other.Location - Other.CollisionRadius*dir;
			if (AttackerHitCount >= NumHitsToUpgradeDamage)
				otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*dir, UpgradedAttackDamageType);
			else
				otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*dir, AttackDamageType);
			MakePeopleScared(class'AnimalAttackMarker');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wrestling the thing back and forth, hurting it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShredAttack
{
	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		local FPSPawn otherpawn;
		local vector hitpos, dir;

		otherpawn = FPSPawn(Other);

		if(otherpawn != None
//			&& otherpawn.Health > 0
			&& otherpawn == Attacker
			&& !bHurtTarget)
		{
			bHurtTarget=true;
			GiveUpCount = 0;	// Reset our give-up count if we successfully hurt something.
			AttackerHitCount++;
			
			dir = Normal(Other.Location - MyPawn.Location);
			hitpos = Other.Location - Other.CollisionRadius*dir;
			if (AttackerHitCount >= NumHitsToUpgradeDamage)
				otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*VRand(), UpgradedAttackDamageType);
			else
				otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*VRand(), AttackDamageType);
			MakePeopleScared(class'AnimalAttackMarker');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToHero
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToHero
{
	// Reset run-to-hero time
	event BeginState()
	{
		Super.BeginState();
		RunToHeroTime = 0.000000;
	}
	
	// Increment run-to-hero time and possibly warp to the hero if we get stuck.
	function Timer()	
	{
		Global.Timer();
		RunToHeroTime += HERO_LOVE_SUB_TIME;
		
		// If we get stuck in this state for too long, warp to the hero instead.
		if (RunToHeroTime >= RunToHeroMax)
			TryToTeleportToHero();
	}
	
	///////////////////////////////////////////////////////////////////////////////
	// If the SetActorTarget functions below can't find a proper path and end up
	// just setting the next move target as the destination itself, this function
	// will be called, so you can possibly exit your state and do something else instead.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		// Just try and teleport
		TryToTeleportToHero();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wrestling the thing back and forth, hurting it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShredDead
{
	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		local FPSPawn otherpawn;
		local vector hitpos, dir;

		otherpawn = FPSPawn(Other);

		if(otherpawn != None
//			&& otherpawn.Health > 0
			&& otherpawn == Attacker
			&& !bHurtTarget)
		{
			bHurtTarget=true;
			GiveUpCount = 0;	// Reset our give-up count if we successfully hurt something.
			AttackerHitCount++;
			
			dir = Normal(Other.Location - MyPawn.Location);
			hitpos = Other.Location - Other.CollisionRadius*dir;
			otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*VRand(), ShredDeadDamageType);
			MakePeopleScared(class'AnimalAttackMarker');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ImOnFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ImOnFire
{
Begin:
	CheckToReturnToNormal();
	SetNextState('ShakeOffFire');
	PickNextDest();
	GotoStateSave('RunOnFire');	
}
state ShakeOffFire extends ImOnFire
{
	///////////////////////////////////////////////////////////////////////////////
	// Shake off the fire that's engulfed us
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		if (MyPawn.MyBodyFire != None)
			MyPawn.MyBodyFire.TakeDamage(999, MyPawn, MyPawn.Location, Vect(0,0,0), class'ExtinguishDamage');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Keep shaking until the fire is gone
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);

		GotoState('ImOnFire');
	}
Begin:
	MyPawn.PlayAttack1();	
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunningScared
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunningScared
{
	// we don't run scared... not for long anyway
Begin:
	Sleep(1.0);
	NextStateAfterGoal();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	NumHitsToUpgradeDamage=3
	PounceDamage=25
	UpgradedAttackDamageType=class'MacheteDamage'
	ShredDeadDamageType=class'ScytheDamage'
	RunToHeroMax=15.000000
}

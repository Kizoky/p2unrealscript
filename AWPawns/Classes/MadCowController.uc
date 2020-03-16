///////////////////////////////////////////////////////////////////////////////
// MadCowController
// Copyright 2004 RWS, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class MadCowController extends AWCowController;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var FPSPawn HateTillDeath;		// If this is set, this thing will get attacked till it death
var Actor ChargeTarget;			// actor we're running after
var float ChargeStartTime;		// level time we started charging
var float MaxChargeTime;		// relative time we will charge for

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const CHARGE_DAMAGE = 60;
const CHARGE_DIST	= 2000;
const CHARGE_UPDATE_TIME= 0.5;
const CHARGE_HIT_RATIO	= 0.013;

const REEL_TIME	= 2.0;

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Trigger functionality:
// If you set InitAttackTag, triggering makes the cat go after that pawn
// If you don't and they're not bPlayerIsFriend or bNoTriggerAttackPlayer, 
// then they'll attack the player
// otherwise, they attack something random around them.
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	local FPSPawn keepp, PlayerP;

	keepp = FPSPawn(FindNearestActorByTag(AWCowPawn(MyPawn).InitAttackTag));

	if(keepp == None
		|| keepp.bDeleteMe
		|| keepp.Health < 0)
	{
		keepp = None;

		if(!MyPawn.bPlayerIsFriend
			&& !MyPawn.bNoTriggerAttackPlayer)
			keepp = GetRandomPlayer().MyPawn;
	}

	HateTillDeath = keepp;
	HandleAttack(keepp, 1);
}

///////////////////////////////////////////////////////////////////////////
// Switch your state appropriately
///////////////////////////////////////////////////////////////////////////
function HandleAttack(Pawn Other, float Damage, optional bool bDoNotRun)
{
	if(bDoNotRun)
		bForceRun=false;
	else // The first time we're bothered, always run unless specified not to
		bForceRun=true;
	SetAttacker(FPSPawn(Other));
	GotoStateSave('ThinkAngry');
}

///////////////////////////////////////////////////////////////////////////////
// Our head was just severed, reel from it for a moment
///////////////////////////////////////////////////////////////////////////////
function HeadSevered(Pawn Other)
{
	SetAttacker(FPSPawn(Other));
	SetNextState('ThinkAngry');
	GotoStateSave('AfterSever');
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Head just cut off... you may be a little disoriented
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AfterSever extends Standing
{
	ignores Bump;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoNextState();
		}
	}

Begin:
	AWCowPawn(MyPawn).PlayAnimReeling();
	Sleep(REEL_TIME);
	GotoNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Pawing the ground, ready to charge
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PreCharge extends Standing
{
	ignores damageAttitudeTo, HandleAttack;

	///////////////////////////////////////////////////////////////////////////////
	// Aim at them now
	///////////////////////////////////////////////////////////////////////////////
	function SetupCharge()
	{
		local vector usept, hitloc, hitnormal;
		local Actor HitActor;

		// Aim past where you're looking
		usept = (CHARGE_DIST*vector(MyPawn.Rotation)) + MyPawn.Location;

		// Check at the last moment and see if there's something else in the way before we
		// charge. If so, run around angry
		HitActor = MyPawn.Trace(hitloc, hitnormal, ChargeTarget.Location, MyPawn.Location, true);
		if(HitActor == ChargeTarget
			|| HitActor == None)
		{
			// Set end and change states
			SetEndPoint(usept, DEFAULT_END_RADIUS);
			SetNextState('FinishCharge');
			GotoStateSave('Charging');
		}
		else
			GotoStateSave('ThinkAngry', 'RunAround');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Charge anyway at the slightest touch
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		if(Pawn(Other) != None)
			SetupCharge();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			SetupCharge();
		}
	}

	function BeginState()
	{
		Super.BeginState();
		// Face who you'll charge
		Focus = ChargeTarget;
	}
Begin:
	AWCowPawn(MyPawn).PlayAnimPreCharge();
	AWCowPawn(MyPawn).PlayPreChargeSound();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Raises head in the air like he butted something
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FinishCharge extends Standing
{
	ignores damageAttitudeTo, HandleAttack;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoStateSave('ThinkAngry');
		}
	}
Begin:
	AWCowPawn(MyPawn).FinishCharge();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ThinkAngry
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ThinkAngry extends Thinking
{
	ignores damageAttitudeTo, HandleAttack;

	///////////////////////////////////////////////////////////////////////////////
	// If you pick something, then you'll precharge first, then you'll charge
	// otherwise, you'll just run around crazily
	///////////////////////////////////////////////////////////////////////////////
	function bool FindTarget()
	{
		local Actor keeptarget;
		local P2Player keepp;

		// If has a head, he can decide where to charge, otherwise, he just runs around
		// all crazy like.
		if(AWCowPawn(MyPawn).bHasHead)
		{
			// Check if we have a target set for us
			if(HateTillDeath != None
				&& HateTillDeath.Health > 0)
				keeptarget = HateTillDeath;
			else if(FRand()< MadCowPawn(MyPawn).PickTargetFreq)
			{
				// Pick the player
				if(FRand()< MadCowPawn(MyPawn).PickDudeFreq)
				{
					keepp = GetRandomPlayer();
					keeptarget = keepp.MyPawn;
				}
				// pick something else to hit
			}

			// If we have a target and can see him from here, chaaaaaaarrrrge!
			if(keeptarget != None
				&& FastTrace(keeptarget.Location, MyPawn.Location))
			{
				// Pick point past the character
				if(FPSPawn(keeptarget) != None)
					SetAttacker(FPSPawn(keeptarget));
				ChargeTarget = keeptarget;
				GotoStateSave('PreCharge');
				return true;
			}
		}
		return false;
	}

Begin:
	// Decide to attack something around you, or just run in general
	if(FindTarget())
RunAround:
		if(!PickRandomDest())
			// Run to some random place I can see (not through walls)
			UseNearestPathNode(2048);
	if(FRand()< AWCowPawn(MyPawn).CalmDownFreq
		&& !bForceRun)
		SetNextState('Thinking');
	else // still going to run
		SetNextState('ThinkAngry');

	// If we didn't pick the dude or something, run around crazily
	if(Frand() < SCARED_SOUND_FREQ)
		AWCowPawn(MyPawn).PlayScaredSound();
	GotoStateSave('RunningAngry');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunningAngry
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunningAngry extends RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event Bump(actor Other)
	{
		if(AngryBump(Other, RunDamage, HIT_RATIO))
		{
			MyPawn.StopAcc();
			GotoStateSave('ThinkAngry');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Charging
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Charging extends RunToTarget
{
	ignores HandleAttack;

	///////////////////////////////////////////////////////////////////////////////
	// When charging we have a very limited actor target point set
	///////////////////////////////////////////////////////////////////////////////
	function SetActorTargetPoint(vector DestPoint, optional bool bStrictCheck)
	{
		FocalPoint = DestPoint;
		Focus = None;
		MovePoint = DestPoint;
		MoveTarget=None;		// make sure to clear the target, or it will use the old one
		bMovePointValid = true;
		UseEndRadius = EndRadius;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event Bump(actor Other)
	{
		if(Pawn(Other) != None)
		{
			if(AngryBump(Other, ChargeDamage, CHARGE_HIT_RATIO))
			{
				GotoStateSave('FinishCharge');
			}
		}
		else
			AngryBump(Other, ChargeDamage, CHARGE_HIT_RATIO);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		AWCowPawn(MyPawn).EndCharge();
		Super.EndState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		AWCowPawn(MyPawn).BeginCharge();
		ChargeStartTime = Level.TimeSeconds;
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     MaxChargeTime=10.000000
     RunDamage=35.000000
     ChargeDamage=70.000000
}

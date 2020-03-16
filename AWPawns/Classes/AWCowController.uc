///////////////////////////////////////////////////////////////////////////////
// AWCowController
// Copyright 2004 RWS, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWCowController extends AnimalController;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var float RunDamage;		// damage inflicted in these states
var float ChargeDamage;

var bool bForceRun;			// If, after something important happened and we go
							// to a think state that may randomly stop or run, this can
							// force it to run once, then get reset

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const MIN_VELOCITY_FOR_REAL_MOVEMENT = 100;
const LEG_MOTION_CAUGHT_MAX	=	3;

const PICK_NEAREST_VICTIM	=	0.4;

const VICTIM_FIND_RADIUS	=	4096;

const MAX_TURN_WAIT			=	10.0;

const HIT_RATIO				=	0.01;

const FRONT_BUMP_DOT		=	0.8;
const BACK_KICK_DOT			=	-0.5;

const MOO_SOUND_FREQ		=	0.4;
const SCARED_SOUND_FREQ		=	0.5;

const MIN_SMALL_RADIUS		=	50.0;

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Make pawns start dead and at the end of a given animation
///////////////////////////////////////////////////////////////////////////////
function SetToDead()
{
	MyPawn.TakeDamage(MyPawn.HealthMax, None, MyPawn.Location, vect(0, 0, 1), class'P2Damage');
	SetNextState('Destroying');
}
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
	GotoStateSave('ThinkScared');
}

///////////////////////////////////////////////////////////////////////////////
// Play extra hurt noise
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
					   class<DamageType> damageType, vector Momentum)
{
	if ( instigatedBy != pawn 
		&& Damage > 0)
	{
		if(ClassIsChildOf(damagetype, class'BurnedDamage')
			|| ClassIsChildOf(damagetype, class'BurnedDamage')
			|| ClassIsChildOf(damagetype, class'AnthDamage')
			|| ClassIsChildOf(damagetype, class'ElectricalDamage'))
			AWCowPawn(MyPawn).PlayScaredSound();

		damageAttitudeTo(instigatedBy, Damage);
	}
} 

///////////////////////////////////////////////////////////////////////////
// When attacked
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;

	if ( (Other != Pawn) && (Damage > 0) )
	{
		// Something bad happened so tell the others
		if(MyProtestInfo != None)
			MyProtestInfo.DisruptGroup(self, P2Pawn(Other), P2Pawn(Other));

		HandleAttack(Other, Damage);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about this danger
///////////////////////////////////////////////////////////////////////////////
function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
								FPSPawn CreatorPawn, 
								Actor OriginActor,
								vector blipLoc,
								optional out byte StateChange)
{
	DangerPos = blipLoc;

	// Something bad happened so tell the others
	if(MyProtestInfo != None)
		MyProtestInfo.DisruptGroup(self, CreatorPawn, CreatorPawn);

	HandleAttack(CreatorPawn, 1);

	StateChange=1;
	return;
}

///////////////////////////////////////////////////////////////////////////////
// Because animals are more simple, we can have a general 'startled' function
///////////////////////////////////////////////////////////////////////////////
function StartledBySomething(Pawn Meanie)
{
	// Something bad happened so tell the others
	if(MyProtestInfo != None)
		MyProtestInfo.DisruptGroup(self, P2Pawn(Meanie), P2Pawn(Meanie));

	if(Meanie != None)
		DangerPos = Meanie.Location;

	HandleAttack(Meanie, 1);
}

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	local float fcheck;

	// Something bad happened so tell the others
	if(MyProtestInfo != None)
		MyProtestInfo.DisruptGroup(self, Other, Other);

	HandleAttack(Other, 1);
}

///////////////////////////////////////////////////////////////////////////
// Gas is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function GettingDousedInGas(P2Pawn Other)
{
	local float fcheck;

	// Something bad happened so tell the others
	if(MyProtestInfo != None)
		MyProtestInfo.DisruptGroup(self, Other, Other);

	Super.GettingDousedInGas(Other);

	HandleAttack(Other, 1);
}

///////////////////////////////////////////////////////////////////////////////
// I'm attacking or about to attack, so scare everyone around me
///////////////////////////////////////////////////////////////////////////////
function MakePeopleScared(class<AnimalAttackMarker> ADanger)
{
	ADanger.static.NotifyControllersStatic(
		Level,
		ADanger,
		MyPawn, 
		MyPawn, 
		ADanger.default.CollisionRadius,
		MyPawn.Location);
}

///////////////////////////////////////////////////////////////////////////////
// You're getting electricuted
///////////////////////////////////////////////////////////////////////////////
function GetShocked(P2Pawn Doer, vector HitLocation)
{
	if(MyPawn.Physics == PHYS_WALKING)
	{
		SetAttacker(Doer);

		MakeShockerSteam(HitLocation,,true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bumps when cow is calm and standing around
///////////////////////////////////////////////////////////////////////////////
event StandBump(actor Other, out byte StateChange)
{
	local vector HitMomentum, HitLocation, Rot, dir;
	local FPSPawn otherpawn;
	local float fcheck, usedam, dot1;

	if(PeoplePart(Other) != None
		|| (Pawn(Other) != None
			&& AWCowPawn(Other) == None)
		|| Projectile(Other) != None)
	{
		// Make sure it's in front of you before you hurt it
		Rot = vector(MyPawn.Rotation);
		dir = Other.location - MyPawn.location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		if(dot1 < BACK_KICK_DOT)
		{
			GotoState('KickBack');
			StateChange=1;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle bumps with other characters when we're angry and will hurt them
///////////////////////////////////////////////////////////////////////////////
function bool AngryBump(actor Other, float TouchDamage, float hitratio)
{
	local vector HitMomentum, HitLocation, Rot, dir;
	local FPSPawn otherpawn;
	local float fcheck, usedam, dot1;
	
	// Gang check (fixes lag by preventing mad cows from ramming each other endlessly)
	if (FPSPawn(Other) != None && SameGang(FPSPawn(Other)))
		return false;

	// Send this thing flying...
	HitMomentum = MyPawn.Velocity*MyPawn.Mass*hitratio;
	HitMomentum.z = 0;
	HitMomentum.z = VSize(HitMomentum)*(FRand()*0.3 + 0.5);
	//log(Self$" angry bump, hit momentum "$hitmomentum);

	// Kill normal bystander types instantly, the dude, cops, special
	// other characters and such, we just hurt some
	otherpawn = FPSPawn(Other);
	if(otherpawn != None
		&& otherpawn.Health > 0)
	{
		if(PersonPawn(otherpawn) != None
			&& !(otherpawn.bPlayer
				|| otherpawn.IsA('AuthorityFigure')
				|| otherpawn.bPersistent))
			usedam = otherpawn.Health;
		else
			usedam = TouchDamage;

		// Make sure it's in front of you before you hurt it
		Rot = vector(MyPawn.Rotation);
		dir = Other.location - MyPawn.location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		//log(self$" bumping into "$Other$" rad "$Other.CollisionRadius);
		if(dot1 > FRONT_BUMP_DOT
			|| Other.CollisionRadius > MIN_SMALL_RADIUS)
		{
			//log(Self$" other getting hit, damage "$usedam);
			Other.TakeDamage(usedam,
								MyPawn, Other.Location, HitMomentum, AWCowPawn(MyPawn).MyDamage);
			return true;
		}
		else if(otherpawn != None
			&& AnimalController(otherpawn.Controller) != None)
		{
			AnimalController(otherpawn.Controller).StartledBySomething(MyPawn);
			return true;
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do next
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{

	///////////////////////////////////////////////////////////////////////////
	// Use the simple group of pathnodes gathered up the gameinfo to determine
	// a random point to walk to. The problem is we then have to test it
	// and handle not having it return a good path node every time--different
	// but more random than the engine.FindRandomDest.
	///////////////////////////////////////////////////////////////////////////
	function PathNode FindRandomPathNodeDest()
	{
		local PathNode usenode;

		if(PathList.node != None)
		{
			usenode = FindRandomNode(PathList.node, PathList.Length);
			if(FindPathToward(usenode) != None
				|| FastTrace(usenode.Location, MyPawn.Location))
				return usenode;
		}
		return None;
	}

	///////////////////////////////////////////////////////////////////////////
	// If we hate the player, find him and kill him
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local P2Player keepp;

		Super.BeginState();

		// Not dangerous any more
		MyPawn.bDangerous=false;

		if(MyPawn.bPlayerIsEnemy)
		{
			keepp = GetRandomPlayer();
			if(keepp != None)
			{
				HandleAttack(keepp.MyPawn, 1);
			}
		}
	}
Begin:
	if(Frand() < MOO_SOUND_FREQ)
		AWCowPawn(MyPawn).PlayNormalMoo();

	if(FRand() < AWCowPawn(MyPawn).StandThenFeedFreq)
	{
		SetNextState('Thinking','FeedThink');
		GotoStateSave('Standing');
	}
	else if(FRand() < AWCowPawn(MyPawn).FeedFreq)
	{
FeedThink:
		SetNextState('Thinking');
		GotoStateSave('Feeding');
	}
	else
	{
		// walk to some random place, close by, that I can see (not through walls)
		if(!PickRandomDest())
			UseNearestPathNode(2048);
		SetNextState('Thinking');
		GotoStateSave('WalkToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and look around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Standing
{
	///////////////////////////////////////////////////////////////////////////////
	// Check for things hitting me in the butt
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		local byte StateChange;
		StandBump(Other, StateChange);
	}

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
			GotoNextState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local vector dir, rot;

		PrintThisState();
		MyPawn.StopAcc();

		// face forwards
		Focus = None;
		rot = vector(MyPawn.Rotation);
		dir = MyPawn.Location + 100*rot;
		FocalPoint = dir;
	}
Begin:
	if(Frand() < MOO_SOUND_FREQ)
		AWCowPawn(MyPawn).PlayNormalMoo();
	MyPawn.PlayAnimStanding();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Eat from the ground, standing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Feeding extends Standing
{
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
			if(FRand() < AWCowPawn(MyPawn).FeedFreq)
				GotoState('Feeding', 'DoFeed');
			else
				GotoNextState();
		}
	}

Begin:
DoFeed:
	AWCowPawn(MyPawn).PlayAnimFeeding();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Got hit in the butt with a sledge
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ButtHit extends Standing
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, GetReadyToReactToDanger,
		StartledBySomething, RespondToTalker, GettingDousedInGas, BodyJuiceSquirtedOnMe,
		Touch, damageAttitudeTo;

	///////////////////////////////////////////////////////////////////////////////
	// Got it back out and it takes off
	///////////////////////////////////////////////////////////////////////////////
	function FinishUp(Actor Other)
	{
		HandleAttack(FPSPawn(Other), 1);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for player getting hammer back
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		if(AWDude(Other) != None)
		{
			if(AWCowPawn(MyPawn).CheckGetHammer(AWDude(Other)))
				FinishUp(Other);
		}
	}

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
			GotoStateSave('ButtStand');
		}
	}

Begin:
	AWCowPawn(MyPawn).PlayAnimButtHit();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Standing with sledge in butt
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ButtStand extends ButtHit
{
Begin:
	AWCowPawn(MyPawn).PlayAnimButtStand();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Kick with back legs
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state KickBack extends ButtStand
{
	ignores Bump;

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
			GotoStateSave('ThinkScared');
		}
	}

Begin:
	AWCowPawn(MyPawn).PlayAnimKick();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTarget
{

	///////////////////////////////////////////////////////////////////////////////
	// Move to the left or right, if we notice we're hung up, when we should be 
	// moving
	///////////////////////////////////////////////////////////////////////////////
	function DodgeThinWall()
	{
		local vector startdir, usevect;

		//log("dodge "$VSize(Pawn.Velocity));
		// If we're stopped or in the same spot.
		if(VSize(Pawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT)
		{
			LegMotionCaughtCount++;
			if(LegMotionCaughtCount > LEG_MOTION_CAUGHT_MAX)
				NextStateAfterGoal();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// If hit by a running human, then ramage
	///////////////////////////////////////////////////////////////////////////////
	event Bump(actor Other)
	{
		local vector HitMomentum, HitLocation;
		local P2Pawn otherpawn;
		local float fcheck;
		local byte StateChange;

		StandBump(Other, StateChange);
		
		if(StateChange == 0)
		{
			otherpawn = P2Pawn(Other);

			if(otherpawn != None)
			{
				if(!otherpawn.bIsWalking)
					HandleAttack(otherpawn, 1);
			}
		}
	}
	
	function BeginState()
	{
		MyPawn.ChangeAnimation();
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ThinkScared
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ThinkScared extends Thinking
{
	ignores damageAttitudeTo, HandleAttack;

Begin:
	// run to some random place I can see (not through walls)
	if(!PickRandomDest())
		UseNearestPathNode(2048);
	if(FRand()< AWCowPawn(MyPawn).CalmDownFreq
		&& !bForceRun)
		SetNextState('Thinking');
	else // still going to run
		SetNextState('ThinkScared');
	bForceRun=false;
	if(Frand() < SCARED_SOUND_FREQ)
		AWCowPawn(MyPawn).PlayScaredSound();
	GotoStateSave('RunningScared');
}

///////////////////////////////////////////////////////////////////////////////
// RunToTarget - plays running sound
///////////////////////////////////////////////////////////////////////////////
state RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// Start running sound
		AWCowPawn(MyPawn).StartRunningSound();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();

		// Stop running sound
		AWCowPawn(MyPawn).StopRunningSound();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunningScared
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunningScared extends RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event Bump(actor Other)
	{
		if(AngryBump(Other, RunDamage, HIT_RATIO))
		{
			MyPawn.StopAcc();
			GotoStateSave('ThinkScared');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Protest walk to next loop point
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ProtestToTarget
{
	///////////////////////////////////////////////////////////////////////////
	// A protestor in a group has been disrupted, so do something about it.
	///////////////////////////////////////////////////////////////////////////
	function ProtestingDisrupted(FPSPawn NewAttacker, FPSPawn NewInterestPawn,
								optional bool bKnowAttacker)
	{
		HandleAttack(NewAttacker, 1);
		// clear our protestor info
		MyProtestInfo = None;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		MyPawn.MyLoopPoint = MyPawn.MyLoopPoint.NextPoint;

		bStraightPath=true;
		SetNextState(GetStateName());
		SetEndGoal(MyPawn.MyLoopPoint, DEFAULT_END_RADIUS);

		GotoState(GetStateName(), 'Begin');
		BeginState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();

		// Something bad happened so tell the others
		if(MyProtestInfo != None)
			MyProtestInfo.DisruptGroup(self, Attacker, InterestPawn);
	}
Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,MyPawn.MovementPct,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,MyPawn.MovementPct,true);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// March walk to next loop point
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state MarchToTarget
{
	ignores HandleStasisChange;
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ImOnFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ImOnFire extends Ramaging
{
	ignores CatchOnFire, StartledBySomething;
}
*/
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     RunDamage=25.000000
     ChargeDamage=25.000000
}

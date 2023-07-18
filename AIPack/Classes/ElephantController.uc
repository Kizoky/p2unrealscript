///////////////////////////////////////////////////////////////////////////////
// ElephantController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ElephantController extends AnimalController;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const CHARGE_DAMAGE = 50;

const MIN_VELOCITY_FOR_REAL_MOVEMENT = 100;
const LEG_MOTION_CAUGHT_MAX=3;

const PICK_NEAREST_VICTIM = 0.4;

const VICTIM_FIND_RADIUS = 4096;

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Make pawns start dead and at the end of a given animation
///////////////////////////////////////////////////////////////////////////////
function SetToDead()
{
	MyPawn.TakeDamage(MyPawn.Health, None, MyPawn.Location, vect(0, 0, 1), class'P2Damage');
	SetNextState('Destroying');
}
///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// When attacked
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;

	if ( (P2Pawn(Other) != None) && (Damage > 0) )
	{
		// Something bad happened so tell the others
		if(MyProtestInfo != None)
			MyProtestInfo.DisruptGroup(self, P2Pawn(Other), P2Pawn(Other));

		if(Attacker == None)
		{
			SetAttacker(FPSPawn(Other));
			if (MyPawn.bElephantNoRearUp)
			{
				// Play angry sound here, because Trumpet state doesn't do it.
				MyPawn.PlayAngrySound();
				GotoStateSave('Trumpet');
			}
			else
				GotoStateSave('Rearup');
		}
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
	// If this thing doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses
		|| MyPawn.bIgnoresHearing)
		return;
		
	// Ignore it if it's a parade marker or something else harmless
	if (ClassIsChildOf(dangerhere, class'ParadeMarker'))
		return;

	DangerPos = blipLoc;

	// Something bad happened so tell the others
	if(MyProtestInfo != None)
		MyProtestInfo.DisruptGroup(self, CreatorPawn, CreatorPawn);

	if(FRand() <= 0.5 && !MyPawn.bElephantNoRearUp)
		GotoStateSave('Rearup');
	else
		GotoStateSave('Trumpet');

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

	if(FRand() <= 0.5 && !MyPawn.bElephantNoRearUp)
		GotoStateSave('Rearup');
	else
		GotoStateSave('Trumpet');
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

	// sometimes buck and stuff when getting sprayed
	fcheck = FRand();
	if(fcheck < 0.05)
		GotoStateSave('GoreArea');
	else if(fcheck  < 0.1)
		GotoStateSave('StompArea');
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

	// sometimes buck and stuff when getting sprayed
	fcheck = FRand();
	if(fcheck < 0.05)
		GotoStateSave('GoreArea');
	else if(fcheck  < 0.1)
		GotoStateSave('StompArea');
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

event PreSaveGame()
	{
	Super.PreSaveGame();
	log(self$" my state "$GetStateName());
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
				SetAttacker(keepp.MyPawn);
				if (!MyPawn.bElephantNoRearUp)
					GotoStateSave('Trumpet');
				else
					GotoStateSave('Rearup');
			}
		}
	}
Begin:
	Sleep(2*FRand());

	// walk to some random place I can see (not through walls)
	if(!PickRandomDest())
		Goto('Begin');	// Didn't find a valid point, try again
	SetNextState('Thinking');
	GotoStateSave('WalkToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Attacking
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Attacking
{
	ignores GetReadyToReactToDanger, StartledBySomething, GettingDousedInGas,
		BodyJuiceSquirtedOnMe;

	///////////////////////////////////////////////////////////////////////////
	// Decide what to do after this state
	///////////////////////////////////////////////////////////////////////////
	function bool DecideNext()
	{
		if(Attacker != None)
			InterestPawn = Attacker;
		if(InterestPawn != None)
		{
			SetEndGoal(InterestPawn, DEFAULT_END_RADIUS);
			SetNextState('Ramaging');
			return true;
		}

		return false;
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		local vector dir;

		if ( (P2Pawn(Other) != None) && (Damage > 0) )
		{
			if(Attacker == None)
			{
				SetAttacker(FPSPawn(Other));
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);

		//log("anim end "$channel);
		// Check for the base channel only
		if(channel == 0)
		{	
			if(DecideNext())
				GotoStateSave('ChargeAtTarget');
			else
				GotoStateSave('Ramaging');
		}
	}

	function BeginState()
	{
		PrintThisState();
		MyPawn.bDangerous=true;	// make sure people know you're dangerous
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Trumpet your noises
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Trumpet extends Attacking
{
Begin:
	// stop and wait a second
	MyPawn.StopAcc();

	// now trumpet
	MyPawn.PlayGetScared();

	// scare people after a while
	Sleep(FRand() + 0.5);
	MakePeopleScared(class'AnimalAttackMarker');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Rearup
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Rearup extends Attacking
{
Begin:
	// stop and wait a second
	MyPawn.StopAcc();

	// now rear up
	MyPawn.PlayGetAngered();
	// scare people after a while
	Sleep(FRand() + 0.5);
	MakePeopleScared(class'AnimalAttackMarker');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GoreArea
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GoreArea extends Attacking
{
Begin:
	MyPawn.StopAcc();
//	Sleep(FRand());
	MyPawn.PlayAttack2();
	// scare people after a while
	Sleep(FRand() + 0.5);
	MakePeopleScared(class'AnimalAttackMarker');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stomp
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StompArea extends Attacking
{
Begin:
	MyPawn.StopAcc();
//	Sleep(FRand());
	MyPawn.PlayAttack1();
	// scare people after a while
	Sleep(FRand() + 0.5);
	MakePeopleScared(class'AnimalAttackMarker');
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

		otherpawn = P2Pawn(Other);

		if(otherpawn != None
			&& otherpawn.Health > 0
			&& otherpawn != None)
		{
			if(!otherpawn.bIsWalking)
				GotoStateSave('Ramaging');
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
state ProtestToTarget extends WalkToTarget
{
	ignores RespondToTalker, DodgeThinWall;

	///////////////////////////////////////////////////////////////////////////
	// A protestor in a group has been disrupted, so do something about it.
	///////////////////////////////////////////////////////////////////////////
	function ProtestingDisrupted(FPSPawn NewAttacker, FPSPawn NewInterestPawn,
								optional bool bKnowAttacker)
	{
		GotoStateSave('Ramaging');
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
		SetEndGoal(MyPawn.MyLoopPoint, PROTEST_END_RADIUS);

		GotoState(GetStateName(), 'Begin');
		BeginState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		//MyPawn.SetProtesting(true);

		// Store the offset speed for the various rows of people
		//CurrentFloat = MyProtestInfo.MoveReductionPct;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		//MyPawn.SetProtesting(false);

		// Drop things if you had them in your hands
		//MyPawn.DropBoltons(MyPawn.Velocity);

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
state MarchToTarget extends ProtestToTarget
{
	ignores HandleStasisChange;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ChargeAtTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ChargeAtTarget extends RunToTarget
{
	ignores GettingDousedInGas, GetReadyToReactToDanger, StartledBySomething,
		BodyJuiceSquirtedOnMe;

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
	// Handle bumps with other characters
	///////////////////////////////////////////////////////////////////////////////
	event Bump(actor Other)
	{
		local vector HitMomentum, HitLocation;
		local FPSPawn otherpawn;
		local float fcheck, usedam;

		// Send this thing flying...
		HitMomentum = MyPawn.Velocity*MyPawn.Mass;
		HitMomentum.z = 0;
		HitMomentum.z = VSize(HitMomentum)*(FRand()*0.3 + 0.5);

		// Kill normal bystander types instantly, the dude, cops, special
		// other characters and such, we just hurt some
		otherpawn = FPSPawn(Other);
		if(otherpawn != None
			&& otherpawn.Health > 0)
		{
			if(otherpawn != None
				&& !(otherpawn.bPlayer
					|| otherpawn.IsA('AuthorityFigure')
					|| otherpawn.bPersistent))
				usedam = otherpawn.Health;
			else
				usedam = CHARGE_DAMAGE;

			Other.TakeDamage(usedam,
								MyPawn, Other.Location, HitMomentum, class'SmashDamage');

			// Only do complicated stuff when you hit someone
			if(P2Pawn(Other) != None)
			{
				// Check what to do now that you've smashed something.
				fcheck = FRand();
				if(fcheck < 0.4)
					GotoStateSave('GoreArea');
				else if(fcheck  < 0.8 || MyPawn.bElephantNoRearUp)
					GotoStateSave('StompArea');
				else
					GotoStateSave('Rearup');
			}
			else if(otherpawn != None
				&& AnimalController(otherpawn.Controller) != None
				&& ElephantController(otherpawn.Controller) == None)
			{
				AnimalController(otherpawn.Controller).StartledBySomething(MyPawn);

				GotoStateSave('StompArea');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked, just short circuit
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		local vector dir;
			local float fcheck;

		if ( (P2Pawn(Other) != None) && (Damage > 0) )
		{
			SetAttacker(FPSPawn(Other));
			InterestPawn = Attacker;

			// sometimes buck and stuff
			fcheck = FRand();
			if(fcheck < 0.075)
				GotoStateSave('GoreArea');
			else if(fcheck  < 0.15)
				GotoStateSave('StompArea');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		MyPawn.SetAnimRunning();
	}

	///////////////////////////////////////////////////////////////////////////////
	// clear your attacker
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		SetAttacker(None);
		InterestPawn = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Ramaging
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Ramaging
{
	ignores GettingDousedInGas, BodyJuiceSquirtedOnMe,
		GetReadyToReactToDanger, StartledBySomething;

	///////////////////////////////////////////////////////////////////////////////
	// This is slow and stupid, but we want to use this as a 'fast' way to find
	// out how many controllers are active in the level.
	///////////////////////////////////////////////////////////////////////////////
	function int GetPeopleControllerCount()
	{
		local Controller C;
		local int i;

		for( C=Level.ControllerList; C!=None; C=C.nextController )
		{
			if(PersonController(C) != None
				|| PlayerController(C) != None)
				i++;
		}
		return i;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look for someone around me to smash
	///////////////////////////////////////////////////////////////////////////////
	function PickNextVictim()
	{
		local P2Pawn CheckP, UseP, FirstOne;
		local float PickRamp, PickVal;
		local float dist, keepdist;
		local bool bPickNearest;

		dist = VICTIM_FIND_RADIUS;
		keepdist = dist;

		// Get how many pawns are active in the level.
		statecount = GetPeopleControllerCount();
		
		if(FRand() <= PICK_NEAREST_VICTIM)
		{
			// how much more the PickVal will increase, each time we don't get a new person
			PickRamp = FRand()/statecount;
			PickVal = PickRamp;
		}
		else
			bPickNearest=true;

		// check all the pawns around me.
		ForEach VisibleCollidingActors(class'P2Pawn', CheckP, VICTIM_FIND_RADIUS, MyPawn.Location)
		{
			// don't get people behind walls or dead people
			if(CheckP.Health > 0
				&& FastTrace(MyPawn.Location, CheckP.Location))
			{
				if(FirstOne == None)
					FirstOne = CheckP;

				// find the closest one to us
				if(bPickNearest)
				{
					dist = VSize(CheckP.Location - MyPawn.Location);
					if(dist < keepdist)
					{
						keepdist = dist;
						UseP = CheckP;
					}
				}
				else	// otherwise, just randomly pick one by getting more and
					// more likely to choose the next guy as you progress through the list of pawns.
				{
					if(FRand() <= PickVal)
					{
						UseP = CheckP;
						break;
					}
					else
						PickVal += PickRamp;
				}
			}
		}

		if(UseP == None)
			UseP = FirstOne;

		// Go after our next target
		if(UseP != None)
		{
			InterestPawn = UseP;
			SetEndGoal(InterestPawn, DEFAULT_END_RADIUS);
			GotoStateSave('ChargeAtTarget');
		}
		else	// Can't find anything more, so just go back to normal.
		{
			MyPawn.MovementPct = MyPawn.WalkingPct;
			GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Decide to charge, stomp, etc
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		PickNextVictim();
	}

	///////////////////////////////////////////////////////////////////////////////
	// come back to this state again
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.SetAnimRunning();
		SetNextState(GetStateName());
		MyPawn.bDangerous=true;
	}
Begin:
	DecideNextState();
}

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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
}
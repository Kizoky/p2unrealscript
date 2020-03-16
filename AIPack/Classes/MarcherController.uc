///////////////////////////////////////////////////////////////////////////////
// MarcherController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for protestors
///////////////////////////////////////////////////////////////////////////////
class MarcherController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars
var bool bTriggeredAttack;		// We've been triggered into attacking, so we know more than normal
var bool bHasProtestSign;

const PROTEST_SIGN_GROUP = 1;
const PROTEST_SIGN_OFFSET = 68;

///////////////////////////////////////////////////////////////////////////////
// Possess the pawn
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	local Inventory CheckInv;
	Super.Possess(aPawn);
	
	// Find out if they have a protest sign.
	for (CheckInv = aPawn.Inventory; CheckInv != None; CheckInv = CheckInv.Inventory)
	{
		if (CheckInv.InventoryGroup == PROTEST_SIGN_GROUP
			&& CheckInv.GroupOffset == PROTEST_SIGN_OFFSET)
		{
			// We found a sign! We're done
			bHasProtestSign = true;
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make him get mad and attack, because we're walking back where we
// aren't supposed to be and we haven't paid
// Make absolutely sure we've turned off music
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	// Something bad happened so tell the others
	if(MyProtestInfo != None)
		MyProtestInfo.DisruptGroup(self, Attacker, InterestPawn, bTriggeredAttack);

	Super.Trigger(Other, EventInstigator);
}

///////////////////////////////////////////////////////////////////////////
// This is a seperate function so various states (like ProtestToTarget)
// can call this within the same class, and not call down to a super
// like in PersonController. 
///////////////////////////////////////////////////////////////////////////
function BystanderDamageAttitudeTo(pawn Other, float Damage)
{
	if(MyPawn.bIgnoresSenses
		|| MyPawn.bIgnoresHearing)
	{
		// Something bad happened so tell the others
		if(MyProtestInfo != None)
			MyProtestInfo.DisruptGroup(self, Attacker, InterestPawn, bTriggeredAttack);
	}

	Super.BystanderDamageAttitudeTo(Other, Damage);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Init
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state InitFall
{
	function EndState()
	{
		OldEndGoal = MyPawn.MyLoopPoint;
		Super.EndState();
	}
}

/*
Before we had it so they stood around forever and watched things, but it
was too weird, so for the moment, they're acting just like normal people once
they get disturbed.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait around (from a safe distance hopefully) and watch the violence, forever
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchThreateningPawn
{
Begin:
	// look at it for your react time
	Sleep(1.0 - MyPawn.Reactivity + 0.5);

	// Try to react to it's death
	// What you just were interested in has died, see what to do
	if(InterestPawn.Health <= 0
		|| InterestPawn.Controller == None 
		|| InterestPawn.Controller.IsInState('Dying'))
	{
		SetNextState('WatchThreateningPawn');
		ViolenceWatchDeath(InterestPawn);
	}

	// Check to make sure i'm not doing something stupid like standing
	// where the guy can hit me.
	CheckForInLineOfFire(InterestPawn);

	// Check the guy you're looking at for being too close
	if(statecount == 0)
		// 0 means we can see him and he is still a threat,
		// > 0 means we're thinking about not caring anymore
		ReevaluateThreatDistances(InterestPawn);
*/
  /*
	if(statecount > 0)
	{
		log(self$" stop to check for thinking"$(statecount/STOP_WATCHING_RATIO));
		if(FRand() <= (statecount/STOP_WATCHING_RATIO))
		{
			GotoStateSave('Thinking');
		}
	}
*/
/*
	Goto('Begin');// run this state again
}
*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run away forever
// You ignore most stuff and run like an idiot every where
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FleeFromAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// STUBS
	///////////////////////////////////////////////////////////////////////////////
	function DoAttackerCheck()
	{
	}
	function DoCopCheck()
	{
	}

	///////////////////////////////////////////////////////////////////////////////
	// Based on various things around me, decide what to do next
	// We're leaving this state now
	///////////////////////////////////////////////////////////////////////////////
	function PickNextStateNow()
	{
		if(Attacker != None)
			InterestPawn = Attacker;

		SetNextState('FleeFromDanger');
/*
		if(InterestPawn != None)// && Attacker != None)
			SetNextState('WatchThreateningPawn');
		else
		{
			Focus = None;
			FocalPoint = DangerPos;
			SetNextState('WatchForViolence');
		}
		*/
	}

	///////////////////////////////////////////////////////////////////////////////
	// Can never fail, always running
	///////////////////////////////////////////////////////////////////////////////
	function bool CalcProblemDistance()
	{
		CurrentDist = UseSafeRangeMin;
		return true;
	}

Begin:
	TryThisDirection();
	// Only makes him pause like a retard every once in a while
	if(FRand() > UseReactivity)
	{
		Focus = InterestPawn;	// stare at the thing that caused me to run
		Sleep(1.0 - MyPawn.Reactivity);
		//log("recalc run direction");
		CalcRunDirection();
	}
	else
		Sleep(0.0);
	Goto('Begin');// run this state again
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
	ignores RespondToTalker, ForceGetDown, HandleFireInWay, DodgeThinWall, CheckForIntruder,
		DoWaitOnOtherGuy, SetupSideStep, SetupBackStep, AllowOldState, TryToGreetPasserby, RatOutAttacker,
		PrepToWaitOnDoor, DecideToListen, PerformInterestAction, DonateSetup, MoveAwayFromDoor,
		CanStartConversation, HandlePantsDown, FreeToSeekPlayer, HandlePlayerSightReaction,
		SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// When we get triggered, we attack the player.
	///////////////////////////////////////////////////////////////////////////////
	function Trigger( actor Other, pawn EventInstigator )
	{
		local P2Player keepp;

		MyPawn.bIgnoresSenses=false;
		MyPawn.bIgnoresHearing=false;

		// If you don't have the player as your attacker already, then attack
		// him, otherwise, don't execute this
		if(Attacker == None
			|| !Attacker.bPlayer)
		{
			keepp = GetRandomPlayer();

			SetAttacker(keepp.MyPawn);
			InterestPawn = Attacker;
			ProtestingDisrupted(Attacker, InterestPawn,	true);
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// Something annoying, but not really gross or life threatening
	// has been done to me, so check to maybe notice
	///////////////////////////////////////////////////////////////////////////
	function InterestIsAnnoyingUs(Actor Other, bool bMild)
	{
		if(InterestActor == None)
		{
			InterestActor = Other;
			// Turn to idiot
			Focus=Other;
			// Get angry
			MyPawn.SetMood(MOOD_Angry, 1.0);
			// Be annoyed with your Interest pawn
			GotoState('ProtestToTarget', 'Annoyed');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if dude bumps you as you march
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		if(P2Pawn(Other) != None
			&& P2Pawn(Other).Health > 0
			&& P2Pawn(Other).bPlayer)
			InterestIsAnnoyingUs(Other, true);
	}

	///////////////////////////////////////////////////////////////////////////
	// A protestor in a group has been disrupted, so do something about it.
	///////////////////////////////////////////////////////////////////////////
	function ProtestingDisrupted(FPSPawn NewAttacker, FPSPawn NewInterestPawn,
								optional bool bKnowAttacker)
	{
		// We've already been triggered into attacking, so quit now
		if(bTriggeredAttack)
			return;

		if(bKnowAttacker)
			bTriggeredAttack = true;

		if(MyPawn.MyBodyFire == None)
		{
			// decide to fight if you have a weapon, or run if you don't
			if((Attacker != None 
					|| bKnowAttacker)
				&& MyPawn.bHasViolentWeapon)
			{
				// Make them attack him too
				SetAttacker(NewAttacker);
				InterestPawn = NewAttacker;
				if(Attacker != None)
					DangerPos= Attacker.Location;
				else
					DangerPos = MyPawn.Location;
				MakeMoreAlert();
				SaveAttackerData();
				bPreserveMotionValues=true;

				if(bKnowAttacker
					&& Attacker != None)
				{
					SwitchToBestWeapon();
					SetEndPoint(LastAttackerPos, MyPawn.AttackRange.Min);
					SetNextState('ShootAtAttacker', 'LookForAttacker');
					bStraightPath=UseStraightPath();
					GotoStateSave('RunToAttacker');
				}
				else
				{
					SetNextState('RecognizeAttacker');
					GotoStateSave('ConfusedByDanger');
				}
			}
			else
			{
				if(P2Pawn(NewAttacker) != None
					&& !P2Pawn(NewAttacker).bAuthorityFigure)
					SetAttacker(NewAttacker);
				InterestPawn = NewInterestPawn;
				if(InterestPawn != None)
					DangerPos= InterestPawn.Location;
				else
					DangerPos = MyPawn.Location;
				GenSafeRangeMin();
				// If we don't have an attacker, but we do have a weapon
				// then just watch with your gun out
				if(MyPawn.bHasViolentWeapon
					|| Attacker == None)
					SetNextState('WatchForViolence');
				else
					SetNextState('FleeFromAttacker');
				bPreserveMotionValues=true;
				GotoStateSave('ConfusedByDanger');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		OldEndGoal = MyPawn.MyLoopPoint;
		MyPawn.MyLoopPoint = MyPawn.MyLoopPoint.NextPoint;
		// Store the offset speed for this row of people
		CurrentFloat = MyPawn.MyLoopPoint.WalkToReductionPct;

		bStraightPath=true;
		SetNextState(GetStateName());
		SetEndGoal(MyPawn.MyLoopPoint, PROTEST_END_RADIUS);

		GotoState(GetStateName(), 'Begin');
		BeginState();
	}

	///////////////////////////////////////////////////////////////////////////////
	// If we're heading to a new loop point, just walk straight there, if not
	// then use your super
	///////////////////////////////////////////////////////////////////////////////
	function SetActorTarget(Actor Dest, optional bool bStrictCheck)
	{
		if(LoopPoint(Dest) != None)
		{
			MoveTarget = Dest;
			if(!bDontSetFocus)
				Focus = MoveTarget;

			UseEndRadius = MoveTarget.CollisionRadius;
		}
		else
			SetActorTarget(Dest, bStrictCheck);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		MyPawn.SetProtesting(true);
		// Store the offset speed for this row of people
		// This determines how much slower we will walk as we move towards this point
		// It should be 1.0 on straight aways, and less for the group that's tighest
		// in a turn. 
		CurrentFloat = MyPawn.MyLoopPoint.WalkToReductionPct;
		// Switch to a protest sign if they have one, if not then switch to hands
		if (bHasProtestSign)
			SwitchToThisWeapon(PROTEST_SIGN_GROUP, PROTEST_SIGN_OFFSET);
		else
			SwitchToHands();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.SetProtesting(false);

		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);

		// Something bad happened so tell the others
		if(MyProtestInfo != None)
			MyProtestInfo.DisruptGroup(self, Attacker, InterestPawn, bTriggeredAttack);
			
		// Reset protest sign attachment
		if (Pawn.Weapon != None
			&& Pawn.Weapon.ThirdPersonActor != None)
		{
			Pawn.Weapon.ThirdPersonActor.SetRelativeLocation(Pawn.Weapon.ThirdPersonRelativeLocation);
			Pawn.Weapon.ThirdPersonActor.SetRelativeRotation(Pawn.Weapon.ThirdPersonRelativeRotation);
		}
	}
Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,MyPawn.MovementPct*CurrentFloat,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,MyPawn.MovementPct*CurrentFloat,true);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
Annoyed:
	// Stop moving
	MyPawn.StopAcc();
	// Yell something cool
	SayTime = Say(MyPawn.myDialog.lGetBumped);
	// wait while we yell
	PrintDialogue("watch it!");
	Sleep(SayTime);
	// return focus early
	Focus = EndGoal;
	InterestPawn2 = None;
	Sleep(0.5 + FRand()/2);

	MakeLessPatient(HARASS_PATIENCE_LOSS);
	// Reset them yelling
	MyPawn.SetProtesting(false);
	MyPawn.SetProtesting(true);

	// Go back to protesting/marching
	Goto('Begin');
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
	ignores HandleStasisChange, InterestIsAnnoyingUs, GetHitByDeadThing, LookAroundWithHead;
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		MyPawn.SetProtesting(false);
		MyPawn.SetMarching(true);
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.SetMarching(false);
	}
Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,MyPawn.MovementPct*CurrentFloat,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,MyPawn.MovementPct*CurrentFloat,true);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
Annoyed:
	// Stop moving
	MyPawn.StopAcc();
	// Yell something cool
	SayTime = Say(MyPawn.myDialog.lGetBumped);
	// wait while we yell
	PrintDialogue("watch it!");
	Sleep(SayTime);
	// return focus early
	Focus = EndGoal;
	InterestPawn2 = None;
	Sleep(0.5 + FRand()/2);

	MakeLessPatient(HARASS_PATIENCE_LOSS);
	// Reset them yelling
	MyPawn.SetMarching(false);
	MyPawn.SetMarching(true);

	// Go back to protesting/marching
	Goto('Begin');
}

defaultproperties
{
}
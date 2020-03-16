///////////////////////////////////////////////////////////////////////////////
// MilitaryController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for military
///////////////////////////////////////////////////////////////////////////////
class MilitaryController extends PoliceController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// Internal vars
var array<P2Pawn> Teammates;// These are the pawns on my team. 
var int Runaway;

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const COMMENT_ON_NAKED	=	200;

///////////////////////////////////////////////////////////////////////////////
// Override Police and have the ai only switch when they don't already
// have a violent weapon
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToBestWeapon()
{
	// If they don't have a weapon, or they have a non-violent one, then
	// get out their best violent one
	if(P2Weapon(Pawn.Weapon) == None
		|| P2Weapon(Pawn.Weapon).ViolenceRank <= 0)
		Super.SwitchToBestWeapon();
}

///////////////////////////////////////////////////////////////////////////////
// Someone's verbally threatened you.. attack or run
///////////////////////////////////////////////////////////////////////////////
function HandleMeanTalker(FPSPawn Meanie)
{
	InterestPawn = Meanie;
	SetAttacker(InterestPawn);

	if(MyPawn.bHasViolentWeapon)
		GotoStateSave('AssessAttacker');
	else
		GotoStateSave('FleeFromAttacker');
}

///////////////////////////////////////////////////////////////////////////////
// Get the state to handle someone who's aggressive around us. 
// Cops try to arrest him.. military just attacks.
///////////////////////////////////////////////////////////////////////////////
function Name GetAggressiveState()
{
	return 'ShootAtAttacker';
}

///////////////////////////////////////////////////////////////////////////
// Possibly another cop, or someone who's friend with authority. Return
// true if so, false otherwise.
///////////////////////////////////////////////////////////////////////////
function bool FriendWithMe(FPSPawn Other)
{
	// invalid, so not friend
	if(Other == None)
		return false;

	// He's trying to attack a good guy, so not a friend
	if(PersonController(Other.Controller) != None
		&& P2Pawn(PersonController(Other.Controller).Attacker) != None
				&& P2Pawn(PersonController(Other.Controller).Attacker).bAuthorityFigure)
		return false;

	// He's a fellow good guy, don't attack him
	if(P2Pawn(Other) != None
		&& P2Pawn(Other).bAuthorityFigure)
		return true;

	// He's a friend of good guys don't attack him
	if(PersonController(Other.Controller) != None
//		&& PersonController(Other.Controller).Attacker != MyPawn
		&& Other.bFriendWithAuthority)
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Depending on the situation, know the same thing your partner knows..
// if he's attacking someone, back him up, if he's telling someone to freeze,
// then follow along
// Screw the blue wall! Attack the dude cop as necessary
///////////////////////////////////////////////////////////////////////////////
function GainPartnersKnowledge(PersonController NewPartner, out byte Worked, out byte AttackingDudeCop)
{
	if(Attacker == None
		|| Attacker.Health <= 0)
	{
		if(NewPartner != None)
		{
			Focus = NewPartner.Focus;
			InterestPawn = NewPartner.InterestPawn;
			SetAttacker(NewPartner.Attacker);
			Worked=1;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called at the beginning of the game, and after anything's gone wrong
// the team leader builds the team again by linking everyone together
// and pointing them at him. The team is anyone with the same Gang tag.
///////////////////////////////////////////////////////////////////////////////
function BuildTeam()
{
	local P2Pawn CheckP, LastP;

	if(MyPawn.Gang != ""
		&& MyPawn.Gang != "None"
		&& Teammates.Length == 0)
	{
		// Find everyone with your tag, since you're the team leader
		ForEach DynamicActors(class'P2Pawn', CheckP)
		{
			if(CheckP != MyPawn
				&& CheckP.Health > 0
				&& SameGang(CheckP))
			{
				// put him in your list of underlings
				//log(MyPawn$" BuildTeam, finding this guy "$CheckP);
				Teammates.Insert(Teammates.Length, 1);
				Teammates[Teammates.Length-1] = CheckP;

				// If i'm the team leader, i'll help everyone organize
				if(MyPawn.bTeamLeader)
				{
					// And make him point to the guy he should follow
					// (he should follow me, if he's the first, or the last guy)
					if(LastP == None)
						CheckP.MyLeader = MyPawn;
					else
						CheckP.MyLeader = LastP;

					log(MyPawn$" setting "$CheckP$" to have leader of "$CheckP.MyLeader);

					// save the guy we just dealt with
					LastP = CheckP;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Search the area for another cop, if you are the only cop in the area
// make yourself the leader. If there's another cop in the area already
// as the leader, make him your leader
///////////////////////////////////////////////////////////////////////////////
function DetermineLeader(optional bool bForceRedo)
{
}

///////////////////////////////////////////////////////////////////////////////
// Search the area for other cops, and make sure they all do the same
// thing as you, if they have the same attacker as you
// Don't send me to this state too, I'll handle it on my own
///////////////////////////////////////////////////////////////////////////////
function FollowLeadersState(Name UseThisState, 
							optional Name UseNextState, 
							optional Name UseNextLabel,
							optional Actor UseGoal, 
							optional vector UsePoint,
							optional float UseRad,
							optional bool bUpdateAttackerLoc,
							optional bool bRequiresLineOfSight,
							optional bool bClearAttacking)
{
}

///////////////////////////////////////////////////////////////////////////////
// Take the first one, as old leader, and turn him into a follower of NewLeader
// along with anyone else around who cares.
///////////////////////////////////////////////////////////////////////////////
function DoLeaderSwap(P2Pawn OldLeader, P2Pawn NewLeader)
{
	/*
	local P2Pawn CheckP;
	local PoliceController pcont;
	local float RadCheck;

	RadCheck = CHECK_FOR_LEADER_RADIUS;

	// Make sure the old leader, is no longer a leader
	OldLeader.bTeamLeader=false;
	OldLeader.MyLeader=None;

	// Make the new leader official
	NewLeader.bTeamLeader=true;
	NewLeader.MyLeader=None;

	// Tell all pawn cops around me with the same attacker
	// as me, to do this state
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		if(CheckP != OldLeader
			&& CheckP != NewLeader)
		{
			pcont = PoliceController(CheckP.Controller);
			if(pcont != None
				&& (CheckP.MyLeader == OldLeader
				|| CheckP.MyLeader == None))
			// If a cop without a leader, or an old leader, then
			// pick NewLeader
			{
				CheckP.bTeamLeader=false;
				CheckP.MyLeader=NewLeader;
			}
		}
	}

  */
}

///////////////////////////////////////////////////////////////////////////////
// If a leader, see if he knows the attacker still has a weapon, if so
// return true, otherwise, return false, including if you're not a leader.
///////////////////////////////////////////////////////////////////////////////
function bool LeaderSensesWeapon()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// If this was a live player, tell him to drop his weapon
// with a hint on the hud
// Only team leader do this
///////////////////////////////////////////////////////////////////////////////
function PlayerHintDropWeapon(FPSPawn MyAttacker, bool bTurnHintsOn, optional bool bStartAllowingHints)
{
}

///////////////////////////////////////////////////////////////////////////
// Pick to follow your leader or do your own thing (if you are the leader)
///////////////////////////////////////////////////////////////////////////
function PickDestToFollowLeader()
{
	local vector nextpos, dir, checkvec;
	local float userad, useRand;
	local Actor HitActor;
	local vector HitNormal, HitLocation;
	local bool bCatchUp;

	if(MyPawn.bTeamLeader
		|| MyPawn.MyLeader == None
		|| MyPawn.MyLeader.Controller == None)
	{
		if(PickRandomDest())
		{
			SetNextState('Thinking');
			GotoStateSave('WalkToTarget');
		}
		else
			GotoStateSave('Thinking');
	}
	else	// try to get close to my leader
	{
		userad = (DEFAULT_END_RADIUS + MyPawn.CollisionRadius);

		// If our distance to our leader is too far away, then 
		// run to catch up.
		checkvec = MyPawn.MyLeader.Location - MyPawn.Location;
		if(VSize(checkvec) > 3*userad)
			bCatchUp=true;

		// If we need to catch up, or the leader has a valid target,
		// so use his target to run to, before him
		if(MyPawn.MyLeader.Controller.MoveTarget != None
			&& !bCatchUp)
			nextpos = MyPawn.MyLeader.Controller.MoveTarget.Location;
		else
			nextpos = MyPawn.MyLeader.Location;

		dir = vector(MyPawn.MyLeader.Rotation);
		useRand = FRand();
		// This projects a point somewhere around the leader, based on his rotation
		nextpos.x += (userad*dir.y + (useRand*userad)*dir.x);
		nextpos.y += (-userad*dir.x + (useRand*userad)*dir.y);
		// Check first how this point works against the wall
		HitActor = MyPawn.MyLeader.Trace(HitLocation, HitNormal, nextpos, MyPawn.MyLeader.Location, true);
		if(HitActor != None
			&& HitActor != MyPawn)
		{
			// move it back from the thing it hit
			//if(VSize(nextpos - HitLocation) < MyPawn.CollisionRadius)
			nextpos = HitLocation;
			nextpos -= HitNormal*CollisionRadius;
		}
		// Now check along the path we will be walking for any obstructions
		HitActor = MyPawn.MyLeader.Trace(HitLocation, HitNormal, nextpos, MyPawn.Location, true);
		if(HitActor != None
			&& HitActor != MyPawn)
		{
			//log(MyPawn$" this in my path, following leader "$HitActor);
			SetEndGoal(MyPawn.MyLeader, DEFAULT_END_RADIUS + FRand()*DEFAULT_END_RADIUS);
		}
		else
		{
			bStraightPath=true;
			SetEndPoint(nextpos, userad);// + FRand()*DEFAULT_END_RADIUS);
		}
	
		//log(MyPawn$" check for new destination "$nextpos@"Dist"@VSize(NextPos - Pawn.Location));
		
		//!! HACK, find out why the runaway loop is actually occurring
		runaway++;
		if (runaway >= 10000)
		{
			warn(MyPawn$"-"$Self@"WAS STUCK IN A RUNAWAY LOOP PickDestToFollowLeader() &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
			runaway = 0;
			GotoState('Thinking');
			return;
		}

		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		// Check first if you're too close to your destination. If so, wait on your leader
		if(VSize(MyPawn.Location - nextpos) < userad)
		{
			GotoStateSave('WaitForLeader');
			return;
		}

		// Check if you're close enough, to walk to your target
		// or if you're too far, then run
		if(bCatchUp)
			GotoStateSave('RunToLeader');
		else
			GotoStateSave('WalkToLeader');
	}
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
	// Pick to follow your leader or do your own thing (if you are the leader)
	///////////////////////////////////////////////////////////////////////////
	function PickNextDest()
	{
		if(MyPawn.bTeamLeader
			|| MyPawn.MyLeader == None
			|| MyPawn.MyLeader.Controller == None)
		{
			if(PickRandomDest())
			{
				SetNextState('Thinking');
				GotoStateSave('WalkToTarget');
			}
			else
				GotoStateSave('Thinking');
		}
		else	// try to get close to my leader
		{
			SetNextState('Thinking');
			GotoStateSave('WalkToLeader');
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// nothing on my mind when we start
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		if(!SwitchToThisWeapon(class'MachineGunWeapon'.default.InventoryGroup,
							class'MachineGunWeapon'.default.GroupOffset));
		else
			SwitchToBestWeapon();

		// clear vars
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;
		FullClearAttacker();
		SetAttacker(None);
		bReportedPlayer=false;
		CurrentInterestPoint = None;
		InterestPawn=None;
		EndGoal = None;
		bSaidGetDown=false;
		SafePointStatus=SAFE_POINT_INVALID;
		bPanicked=false;
		QLineStatus=EQ_Nothing;
		MyPawn.SetMood(MOOD_Normal, 1.0);
		MyPawn.MyLeader=None;
		MyPawn.StopAllDripping();
		SetNextState('');

		BuildTeam();

		// return to normal alertness
		if(MyPawn != None)
		{
			UseReactivity = MyPawn.Reactivity;
			UsePatience = MyPawn.Patience;
		}

		HandleStasisChange();
	}

Begin:
	if(MyPawn.bTeamLeader)
		Sleep(FRand() + 0.5);
	else
		Sleep(0.1);

	// Check to do a patrol
	if(MyPawn.PatrolNodes.Length > 0)
	{
		SetToPatrolPath();
		GotoNextState();
	}

	// Otherwise walk around randomly
	if(!bPreparingMove)
	{
		// walk to some random place I can see (not through walls)
		PickNextDest();
	}
	else
	{
		Sleep(2.0);
		Goto('Begin');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HandleGuyWithPantsDown
// He hasn't pissed on anyone, but he's running around with his pants down
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandleGuyWithPantsDown
{
	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		if(MyPawn.bTeamLeader)
		{
			if(Enemy != InterestPawn
				&& Attacker != InterestPawn)
			{
				UseAttribute = MyPawn.Reactivity;

				//PrintDialogue("Okay.. this oughta be good.");
				//SayTime = Say(MyPawn.myDialog.lNoticeDickOut, bImportantDialog);
			}
			else	// We're already attacking this guy and we know we hate him
				// so get him
			{
				GoKilling();
				return;
			}
		}
	}

Begin:
	// Stare at the result a minute
	Sleep(SayTime);

	// Found him so decide handle the situation
	// for the moment, only a few care
	if(FRand() <= MyPawn.Curiosity)
	{
		GenSafeRangeMin();
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		GotoStateSave('CommentOnPantsDown');
	}
	else
		GotoState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CommentOnPantsDown
// Military/swat doesn't care about pants down--unless you piss on him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CommentOnPantsDown extends GreetPasserby
{
	///////////////////////////////////////////////////////////////////////////////
	// See if we can see our guy
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		SetRotation(MyPawn.Rotation);

		if(LookAtMe == InterestPawn)
		{
			if(!MyPawn.IsTalking())
				GotoState('CommentOnPantsDown', 'CheckHim');
		}
		else if(LookAtMe.IsA('Bystander')
			&& CanSeePawn(MyPawn, LookAtMe)
			&& !MyPawn.bIgnoresSenses)

			ActOnPawnLooks(LookAtMe);
	}

	function BeginState()
	{
		Super.BeginState();
		Focus = InterestPawn;
		statecount=0;
	}

Begin:
	MyPawn.PlayTurnHeadDownAnim(1.0, 0.5);
	Sleep(FRand());

CheckHim:
	CurrentFloat = VSize(InterestPawn.Location - MyPawn.Location);

	if(WeaponTurnedToUs(InterestPawn, MyPawn))
	{
		if(CurrentFloat < COMMENT_ON_NAKED
			&& statecount == 0)
		{
			SayTime=Say(MyPawn.myDialog.lNoticeDickOut);
			MyPawn.PlayTalkingGesture(1.0);
			PrintDialogue("I've seen bigger");
			statecount++;
			Sleep(SayTime+1.0);
		}
	}

	Sleep(FRand());

Ending:

	GotoState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToLeader
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToLeader extends WalkToTarget
{
	ignores HandleStasisChange;
	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		PickDestToFollowLeader();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PickDestToFollowLeader();
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToLeader
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToLeader extends RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		PickDestToFollowLeader();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're leader is screwing around, so wait on him some
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitForLeader
{
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	Focus = MyPawn.MyLeader;
	Sleep(FRand() + 1.0);
	GotoStateSave('WalkToLeader');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait for leader to arrest him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BackupLeader
{
	///////////////////////////////////////////////////////////////////////////////
	// Determine your sleep time
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		CurrentFloat = Rand(5)*(1.0 - MyPawn.Reactivity) + 1.0;
		CurrentDist = FRand()*NON_LEADER_DIST_TO_ATTACKER + FREEZE_BASE_DIST;
		//log(MyPawn$" wait time "$CurrentFloat$" check dist base "$CurrentDist);
		Focus = Attacker;
	}
Begin:
	Sleep(CurrentFloat);

	// See if he's too close to us with a weapon out
	CheckForTooCloseAttacker();

	// Now see if we're close enough to him
	NeedToWalkCloser(CurrentDist + FRand()*NON_LEADER_DIST_TO_ATTACKER);

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchGuyToIdentifyWeapon
// You can't tell yet, but this guy has something dangerous in his hands
// Maybe get closer to check it out.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchGuyToIdentifyWeapon
{
	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		MyPawn.SetMood(MOOD_Combat, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttacker
// We don't stop killing somone, like cops do.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttacker
{
	//ignores HandleSurrender;
	/*
	///////////////////////////////////////////////////////////////////////////////
	// Ignore beating him--only shoot him--unless the guy who got us involved is
	// a cop, and he's not dead, and he's around to stop me from shooting.
	///////////////////////////////////////////////////////////////////////////////
	function EvaluateAttacker()
	{
		//bHateAttacker=true;
		if(
		SwitchToBestWeapon();
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	// During a fight, decide to stop fighting, if he sort of surrenders.
	///////////////////////////////////////////////////////////////////////////////
	function HandleSurrender(FPSPawn LookAtMe, out byte StateChange)
	{
		if(InterestPawn2 != None)
		{
			if(InterestPawn2.IsA('Police')
				&& InterestPawn2.Health > 0)
			{
				if(InterestPawn.Controller.IsInState('OnTheOffensive'))
					Super.HandleSurrender(LookAtMe, StateChange);
			}
			else
				InterestPawn2 = None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bPatrolJail=false
}
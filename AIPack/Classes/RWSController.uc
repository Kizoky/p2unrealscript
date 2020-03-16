///////////////////////////////////////////////////////////////////////////////
// RWSController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// I work at RWS and will fight for Vince to the death! Or.. pretty close to death at least
//
///////////////////////////////////////////////////////////////////////////////
class RWSController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars
var bool bToldPlayer;		// You've told the player he needs to see vince if this is true
var Actor BadPickup;		// Bad pickup we didn't like

const TELL_DUDE_RADIUS	=	128;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetupTellDude(P2Pawn LookAtMe)
{
	// If it's the dude and he hasn't done it, then tell him to go see vince
	InterestPawn = LookAtMe;
	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	SetEndGoal(LookAtMe, TELL_DUDE_RADIUS);
	SwitchToHands();
	MyPawn.ChangeAnimation();
	SetNextState('TellDudeAboutVince');
	GotoStateSave('WalkToDude');
}

///////////////////////////////////////////////////////////////////////////////
// If the dude hasn't completed the vince errand, tell him
///////////////////////////////////////////////////////////////////////////////
function CheckObservePawnLooks(FPSPawn LookAtMe)
{
	if(LookAtMe.bPlayer
		&& !bToldPlayer
		&& !Level.IsDemoBuild()
		&& !P2GameInfoSingle(Level.Game).CorrectDayForErrand("GetPaycheck", "DAY_A", true)
		&& Attacker != LookAtMe
		&& MyPawn.MyBodyChem == None)
	{
		// if it's the dude and he hasn't done it, then tell him to go see vince
		SetupTellDude(P2Pawn(LookAtMe));
		return;
	}

	Super.CheckObservePawnLooks(LookAtMe);
}

///////////////////////////////////////////////////////////////////////////////
//  Make sure the pickup we're about to go after isn't one we know is bad.
///////////////////////////////////////////////////////////////////////////////
function CheckDesiredThing(Actor DesireMaker, class<TimedMarker> blip, optional out byte StateChange)
{
	if(BadPickup != DesireMaker)
	{
		Super.CheckDesiredThing(DesireMaker, blip, StateChange);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand this way, and play and arcade game.. make a mean face sometimes
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayArcadeGame
{
	ignores SetupTellDude;
	// RWS guys playing keep wanting to play--not to see the dude and then
	// go tell him to see vince
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You see something you want, like money or a donut
//
// Focus here holds the item we're interested, be sure not to clear it!
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateDesiredThing
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function ExamineFirst()
	{
		local P2PowerupPickup ppick;
		// Check if it's still there
		if(Pickup(Focus) != None
			&& !Focus.bDeleteMe)
		{
			ppick = P2PowerupPickup(Focus);

			if(ppick != None)
			{
				if(ppick.Tainted==1)
				{
					BadPickup = ppick;	// Save the one we don't like, so
						// we won't be tricked by it again (can be overwritten)
					GotoState(GetStateName(), 'KickTainted');
				}
			}
		}
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToDude extends WalkToTarget
{
	ignores SetupTellDude, FreeToSeekPlayer;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TellDudeAboutVince
// Dude needs to see vince
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TellDudeAboutVince extends TalkingWithSomeoneMaster
{
	ignores SetupTellDude;
	
Begin:
	if(InterestPawn != None)
	{
		// Make sure dude is alive
		if(InterestPawn.Health > 0)
		{
			// Check just before we tell him, if we've already told him or not
			if(!bToldPlayer)
			{
				// Check first if we don't have anything in the way of us telling
				// him about vince
				if(CanSeePoint(MyPawn, InterestPawn.Location))
				{
					bToldPlayer=true;
					// RWS employee tells dude to go find vince
					PrintDialogue("go find vince");
					TalkSome(MyPawn.myDialog.lRWSEmployee,,true);
					Sleep(SayTime);

					// Dude thanks them
					PrintDialogue(InterestPawn$" thanks ");
					TalkSome(P2Pawn(InterestPawn).myDialog.lThanks, P2Pawn(InterestPawn), true);
					Sleep(SayTime);
				}
			}
		}
		else
			bToldPlayer=true;
	}

	GotoStateSave('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// If it's a buddy, in a gun fight, listen to them and just crouch
	///////////////////////////////////////////////////////////////////////////////
	function ForceGetDown(Pawn Shouter, Pawn AttackingShouter)
	{
		if(MyPawn.Physics == PHYS_WALKING
			&& Shouter.Tag == 'RWSVince')
		{
			MyPawn.ShouldCrouch(true);
		}
		// otherwise ignore him
	}

	///////////////////////////////////////////////////////////////////////////
	// I've been attacked by someone (again)
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		// if not vince, react accordingly
		if(Other == None
			|| Other.Tag != 'RWSVince')
		{
			Super.damageAttitudeTo(Other, Damage);
		}
	}
}


defaultproperties
{
}
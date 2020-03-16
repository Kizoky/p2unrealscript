///////////////////////////////////////////////////////////////////////////////
// VinceController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// Hey everybody! It's Vince Desi!
//
///////////////////////////////////////////////////////////////////////////////
class VinceController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const FIRE_HIM_UPDATE	=	0.5;
const FIRE_HIM_RADIUS	=	256;
const VERBALLY_ABUSE_HIM=   3.0;

///////////////////////////////////////////////////////////////////////////////
// Seperate so some states can block it
///////////////////////////////////////////////////////////////////////////////
function GetReadyToFireDude(Pawn TheDude)
{
	local RWSController rwscont;

	// Look at dude
	Focus = TheDude;
	
	// Gesture for them to come forward
	MyPawn.PlayHelloGesture(1.0);
	
	// Magically tell everyone to not talk to the dude anymore (about seeing him)
	foreach DynamicActors(class'RWSController',rwscont)
		rwscont.bToldPlayer=true;	// Don't bother him anymore

	// wait till he gets close enough to fire him
	GotoStateSave('WaitToFireDude');
}

///////////////////////////////////////////////////////////////////////////////
// Don't do anything else when triggered
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	//STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Thinking
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	///////////////////////////////////////////////////////////////////////////////
	// Wake up vince so he starts noticing you
	///////////////////////////////////////////////////////////////////////////////
	function Trigger( actor Other, Pawn EventInstigator )
	{
		GetReadyToFireDude(EventInstigator);
	}

Begin:
	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

TryAgain:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchForDude
// You have things to tell him in particular
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchForDude
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool DudeIsAround(float checkrad)
	{
		local P2Pawn CheckP;

		ForEach VisibleCollidingActors(class'P2Pawn', CheckP, checkrad, MyPawn.Location)
		{
			// if not me, and not through a wall or something, recognize dude
			if(CheckP != MyPawn 
				&& FastTrace(MyPawn.Location, CheckP.Location)
				&& CheckP.Health > 0
				&& CheckP.bPlayer)
			{
				// look at him to say things
				Focus = CheckP;
				InterestPawn = CheckP;
				return true;
			}
		}
		return false;
	}
	
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		CurrentFloat = VERBALLY_ABUSE_HIM;
		// don't look at the dude now
		Focus = None;
	}

Begin:
	Sleep(CurrentFloat + FRand()*CurrentFloat);
	if(DudeIsAround(TALKING_DIST))
	{
		GotoStateSave('SayMeanThings'); 
	}
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitToFireDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitToFireDude extends WatchForDude
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		CurrentFloat = FIRE_HIM_UPDATE;
	}

Begin:
	Sleep(CurrentFloat);
	if(DudeIsAround(TALKING_DIST))
	{
		GotoStateSave('FireTheDude');
	}
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TalkToDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TalkToDude
{
	ignores InterestIsAnnoyingUs;

	function BeginState()
	{
		PrintThisState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FireTheDude
// scripted, triggered, for errand, Dude got fiyad!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FireTheDude extends TalkToDude
{
Begin:
	FinishRotation();
	// Vince says you're fired
	PrintDialogue("Ya fiyad");
	SayTime = Say(MyPawn.myDialog.lVince_Fired);
	// now gesture
	MyPawn.PlayYourFiredAnim();
	// wait the rest of the talking time
	Sleep(SayTime);

	// Dude says he just started
	PrintDialogue(InterestPawn$"but i just started");
	SayTime = P2Pawn(InterestPawn).Say(P2Pawn(InterestPawn).myDialog.lDude_GetFired);
	Sleep(SayTime);

	// now laugh
	SetNextState('WatchForDude');
	GotoStateSave('LaughAtSomething');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GetCheck
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GetCheck extends TalkToDude
{
Begin:
	FinishRotation();
	// Vince says to get your check
	PrintDialogue("get your check");
	SayTime = Say(MyPawn.myDialog.lVince_GetCheck);

	Sleep(SayTime);

	if(MyNextState != 'None'
		&& MyNextState != '')
	{
		SetAttacker(None);
		GotoNextState();
	}
	else
	{
		GotoStateSave('Thinking');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're laughing at something
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LaughAtSomething
{
	ignores InterestIsAnnoyingUs;

	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		if(MyOldState == 'FireTheDude')
		{
			GotoStateSave('GetCheck');
		}
		else if(MyNextState != 'None'
			&& MyNextState != '')
		{
			SetAttacker(None);
			GotoNextState();
		}
		else
		{
			GotoStateSave('Thinking');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SayMeanThings
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SayMeanThings extends TalkToDude
{
Begin:
	FinishRotation();
	PrintDialogue("random insults");
	SayTime = Say(MyPawn.myDialog.lVince_Insults);
	// wait a second
	Sleep(1.0);
	// now gesture
	MyPawn.PlayTellOffAnim();
	// wait the rest of the talking time, plus a little for fast insults.
	Sleep(SayTime);

	// sometimes laugh at him
	if(FRand() <= 0.3)
	{
		SetNextState('WatchForDude');
		GotoStateSave('LaughAtSomething');
	}
	else
	{
		GotoStateSave('WatchForDude');
	}
}

defaultproperties
{
}
///////////////////////////////////////////////////////////////////////////////
// Survivalist Controller.
///////////////////////////////////////////////////////////////////////////////
class SurvivalistController extends MilitaryController;

///////////////////////////////////////////////////////////////////////////////
// We've seen the pawn, now decide if we care
// Returns true if there state changes at some point
///////////////////////////////////////////////////////////////////////////////
function AuthorityActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
{
	// If it's the dude, and I hate him, act now
	// unless he's not dressed like the dude, in which case, don't
	// recognize him
	if(MyPawn.bPlayerIsEnemy 
		&& LookAtMe.bPlayer
		&& DudeDressedAsDude(LookAtMe))
	{
		// decide to fight if you have a weapon, or run if you don't
		if(MyPawn.bHasViolentWeapon)
		{
			// if I'm not attacking anyone already--esp. not the dude
			// then decide to recognize him
			if(Attacker == None)
			{
				InterestPawn = LookAtMe;
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				GotoStateSave('SightedHatedGuy');
				StateChange=1;
			}
			else if(!IsInState('SightedHatedGuy'))
				// we already know we hate him (if we're not trying to decide already)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				SaveAttackerData(LookAtMe);
				GotoStateSave('RecognizeAttacker');
				StateChange=1;
			}
			return;
		}
		else
		{
			DangerPos = LookAtMe.Location;
			GenSafeRangeMin();
			InterestPawn = LookAtMe;
			GotoStateSave('ShyToSafeDistance');
			StateChange=1;
			return;
		}
	}

	Super.AuthorityActOnPawnLooks(LookAtMe, StateChange);
}

///////////////////////////////////////////////////////////////////////////
// We don't get sick or puke. Exception: Anthrax, somehow.
// We rig anthrax to a modifier of 99 here
///////////////////////////////////////////////////////////////////////////
function CheckToPuke(optional float modifier, optional bool bForce, optional out byte StateChange)
{
	if (modifier == 99)
		Super.CheckToPuke(modifier, bForce, StateChange);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// See what the wetness on us is. If we're facing the pissing person, then
// we short-circuit because we immediately know what's happening.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateWetness
{
	///////////////////////////////////////////////////////////////////////////////
	// We're not affected by piss, because we have radiation/biosuits
	// Just kick his butt
	///////////////////////////////////////////////////////////////////////////////
	function RunAwayOrFight()
	{
		local vector dir;

		SetAttacker(InterestPawn);
		Focus = InterestPawn;

			// Make our leader tell everyone to beat you, or do it myself, if I'm the leader
			if(MyPawn.MyLeader != None
				&& PoliceController(MyPawn.MyLeader.Controller) != None)
				PoliceController(MyPawn.MyLeader.Controller).GoKilling();
			else
				GoKilling();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SightedHatedGuy
// Hey--it's that guy I hate! Be confused at first, then realize we
// hate him and attack.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SightedHatedGuy
{
	///////////////////////////////////////////////////////////////////////////////	
	// Go attacking
	///////////////////////////////////////////////////////////////////////////////
	function AttackHim()
	{
		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);

		GotoStateSave('AssessAttacker');
	}

	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function bool RecognizeHim()
	{
		local float dist;

		// Steven: Recognize him immediately if he's wielding a dangerous weapon.
		if(ConcernedAboutWeapon(P2Weapon(Attacker.Weapon)))
		{
			MakeMoreAlert();
			SayTime=0;
			return true;
		}
		// Steven: End fix
		dist = VSize(Attacker.Location - MyPawn.Location);

		// Turrets say things, but don't wait to attack, and they
		// recognize instantly.
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			SayTime=0;
			// Don't record a time, so you'll attack quicker
			if(MyPawn.bPlayerHater)
			{
				PrintDialogue("I hate you!");
				Say(MyPawn.myDialog.lLynchMob);
			}
			else
			{
				PrintDialogue("Hey, it's the player enemy!");
				Say(MyPawn.myDialog.lSeesEnemy);	// Don't record a time, so you'll attack quicker
			}
			return true;
		}
		// Closer the are, the more likely he will recogize you (unless you're
		// in riot mode, then you just attack all the time)
		else if(FRand() > (2*dist)/(P2Pawn(Attacker).ReportLooksRadius)
			|| MyPawn.bRiotMode)
		{
			if(MyPawn.bPlayerHater)
			{
				PrintDialogue("I hate you!");
				SayTime = Say(MyPawn.myDialog.lLynchMob);
			}
			else
			{
				PrintDialogue("Hey, it's the player enemy!");
				SayTime = Say(MyPawn.myDialog.lSeesEnemy);
			}
			return true;
		}
		else // if not, go back to watching
		{
			return false;
		}
	}

	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;
		statecount = 0;
		MyPawn.SetMood(MOOD_Combat, 1.0);
		if(InterestPawn.bPlayer
			&& InterestPawn.Health > 0)
			bImportantDialog=true;
		else
			bImportantDialog=false;
	}
	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		bImportantDialog=false;
		Super.EndState();
	}
Begin:
	Sleep(0.0);
	if(RecognizeHim())
	// You know you hate him, so shout then, start
	// attacking
	{
		Sleep(SayTime);
	}
	else // you're too far away to be sure.
	{
		statecount++;
		if(FRand() > float(statecount)/10)
		{
			// try to recognize him again after a sec
			Sleep(1.0);
			Goto('Begin');
		}
		else	// give up on him
		{
			if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
			{
				SetToTurret();
				GotoNextState(true);
			}
			else
				GotoStateSave('Thinking');
		}
	}

	AttackHim();
}

///////////////////////////////////////////////////////////////////////////////
// MuggerController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for muggers.
// We store our prey in the InterestPawn
//
///////////////////////////////////////////////////////////////////////////////
class MuggerController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars
var float TimeWatchingPrey;		// Vague time you've spent watching your prey. Eventually
								// used to determine to mug them or not

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const FIND_VICTIM_RAD		= 3000;
const STARE_POSSIBLE_COUNT  = 2;
const STARE_COUNT			= 6;
const START_APPROACH_RADIUS	= 2500;
const RUN_TO_PREY			= 1800;
const WALK_TO_PREY			= 500;

const PICK_NPC_FOR_MUGGING		= 0.3;
const PICK_PLAYER_FOR_MUGGING	= 0.8;

const MUG_MAX_RADIUS		= 350;
const MUG_MIN_RADIUS		= 150;

const LOOK_SHIFTILY_FREQ	= 4;

const PREY_CHECK_TIME		= 2.0;
const WATCH_PREY_MIN		= 4.0;
const WATCH_PREY_MAX		= 60.0;
const MONEY_WAIT_UPDATE		= 0.7;

const PLAYER_WAIT_RAND		= 10;
const PLAYER_WAIT_BASE		= 10;
const PLAYER_WAIT_MIN		= 6;

const CASH_GIVE_RAND		= 50;
const CASH_GIVE_BASE		= 10;

const MUG_FREQ				= 3;


///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like) using PawnInitialState
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Find a player and kick his butt
///////////////////////////////////////////////////////////////////////////////
function SetToMugPlayer(FPSPawn PlayerP)
{
	local FPSPawn keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer().MyPawn;
	else
		keepp = PlayerP;

	// check for some one to attack
	if(keepp != None)
	{
		InterestPawn = keepp;
		if(PreyIsInvalid())
		{
			SetNextState('Thinking', 'TryAgain');
		}
		else
		{
			SetEndGoal(InterestPawn, MUG_MIN_RADIUS);
			ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
			SetNextState('RunToTarget');
		}
	}
}
///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like) using PawnInitialState
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Force them to mug the player
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	local byte StateChange;

	MyPawn.bIgnoresSenses=false;
	MyPawn.bIgnoresHearing=false;

	if(!MyPawn.bPlayerIsFriend)
	{
		if(MyPawn.bHasViolentWeapon)
		{
			SetToMugPlayer(FPSPawn(Other));
			GotoNextState();
			if(InterestPawn != None)
			{
				if(!InterestPawn.bPlayer)
					SetNextState('DoNonPlayerMugging');
				else
					SetNextState('DoPlayerMugging');
			}
			StateChange = 1;
		}
	}
	if(StateChange == 0)
		Super.Trigger(Other, EventInstigator);
}

///////////////////////////////////////////////////////////////////////////////
// Called by the interest points to see if we're interested in doing this
// Don't allow if we're focussed on someone
///////////////////////////////////////////////////////////////////////////////
function PerformInterestAction(InterestPoint IPoint, out byte AllowFlow)
{
	if(InterestPawn == None)
		AllowFlow=1;
}

///////////////////////////////////////////////////////////////////////////////
// Make me a marker
///////////////////////////////////////////////////////////////////////////////
function MakeMarker(class<TimedMarker> ADanger,
					FPSPawn originpawn, 
					FPSPawn creatorpawn)
{
	ADanger.static.NotifyControllersStatic(
		Level,
		ADanger,
		originpawn, 
		creatorpawn, 
		ADanger.default.CollisionRadius,
		originpawn.Location);
}

///////////////////////////////////////////////////////////////////////////
// Returns true if our interestpawn is dead or doing something else.
///////////////////////////////////////////////////////////////////////////
function bool PreyIsInvalid()
{
	return (InterestPawn == None
			|| InterestPawn.bDeleteMe
			|| InterestPawn.Health <= 0
			|| (PersonController(InterestPawn.Controller) != None
				&& PersonController(InterestPawn.Controller).Attacker != None));
}

///////////////////////////////////////////////////////////////////////////////
// You're getting the money
///////////////////////////////////////////////////////////////////////////////
function bool GrabbingMoney()
{
	local P2PowerupPickup ppick;

	// Check if it's still there
	if(Pickup(Focus) != None
		&& !Focus.bDeleteMe)
	{
		ppick = P2PowerupPickup(Focus);

		// Say you can grab it.
		MyPawn.bCanPickupInventory=true;
		// Force a touch to register the grab
		Focus.Touch(MyPawn);
		// Say you can't grab anything anymore
		MyPawn.bCanPickupInventory=false;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////
// Scope the people around you first and pick some hapless person
///////////////////////////////////////////////////////////////////////////
function PickSomePrey()
{
	local P2Pawn CheckP;
	local PersonController perc;
	local bool bPickThisGuy;

	InterestPawn = None;
	// Make sure we are being rendered currently before starting our
	// mugging stuff
	if(MyPawn.bHasViolentWeapon)
//		&& MyPawn.LastRenderTime + 1.0 >= Level.TimeSeconds)
	{
		ForEach CollidingActors(class'P2Pawn', CheckP, FIND_VICTIM_RAD, MyPawn.Location)
		{
			// If not me
			if(CheckP != MyPawn
				// Not who we already looked at
				&& InterestPawn != CheckP
				// if still alive (and not dying)
				&& CheckP.Health > 0
				// Not persistant (those are important people)
				&& !CheckP.bPersistent
				// See if we have a line of sight to them
				&& CanSeePawn(MyPawn, CheckP)
				// Only try to arrest bystanders--dude is a bystander--and not cops 
				// or swat.
				&& CheckP.IsA('Bystander')
				// Not friends with me
				&& !SameGang(CheckP))
			{
				if(!CheckP.bPlayer)
				{
					// Make sure the person we're checking out isn't important
					// and isn't currently in trouble somehow or another
					perc = PersonController(CheckP.Controller);
					if(perc.Attacker == None
						&& perc.InterestPawn == None
						&& CashierController(perc) == None
						&& MuggerController(perc) == None)
					{
						bPickThisGuy=true;
					}
				}
				else	// Make sure the player has some money first
				{
					if(P2Player(CheckP.Controller) != None
						&& P2Player(CheckP.Controller).CashPlayerHas() > 0)
						bPickThisGuy=true;
				}

				if(bPickThisGuy)
				{
					// set our prey
					InterestPawn = CheckP;
					statecount = 1 + Rand(STARE_POSSIBLE_COUNT);
					return;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// Run over to them and get ready to mug them
///////////////////////////////////////////////////////////////////////////
function PrepToMug()
{
	if(PreyIsInvalid())
	{
		GotoStateSave('Thinking');
	}
	else
	{
		SetEndGoal(InterestPawn, MUG_MIN_RADIUS);
		if(!InterestPawn.bPlayer)
			SetNextState('DoNonPlayerMugging');
		else
			SetNextState('DoPlayerMugging');
		ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
		GotoStateSave('RunToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do next
// We don't randomly chat with people
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	ignores CanBeMugged;

Begin:
	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

	// Check first to try to mug someone
	PickSomePrey();

	if(InterestPawn != None)
		GotoStateSave('CheckOutPossiblePrey');

TryAgain:
	Sleep(FRand() + 0.5);

	// Check to do a patrol
	if(MyPawn.PatrolNodes.Length > 0)
	{
		Sleep(2.0);
		SetToPatrolPath();
		GotoNextState();
	}

	// walk to some random place I can see (not through walls)
	SetNextState('Thinking');
	if(!PickRandomDest())
		Goto('TryAgain');	// Didn't find a valid point, try again
	GotoStateSave('WalkToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Look at someone and think about robbing them
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CheckOutPossiblePrey
{
	ignores RespondToTalker, PerformInterestAction, RatOutAttacker, CheckDeadBody, CheckDeadHead,
		WatchFunnyThing, CheckDesiredThing, CheckForIntruder, CanStartConversation, 
		FreeToSeekPlayer, CanBeMugged, ForceGetDown;
	
	///////////////////////////////////////////////////////////////////////////////
	// If you lose sight of them, or they die, stop watching them
	///////////////////////////////////////////////////////////////////////////////
	function CheckPrey()
	{
		if(InterestPawn == None
			|| InterestPawn.Health <= 0
			|| !FastTrace(InterestPawn.Location, MyPawn.Location))
			WatchSomeoneElse();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function WatchSomeoneElse()
	{
		PickSomePrey();
		if(InterestPawn != None)
			GotoStateSave('CheckOutPossiblePrey');
		else
			GotoStateSave('Thinking', 'TryAgain');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Check for bumping the guy you want to mug
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local byte StateChange;

		// If you bump you're prey, just mug them now
		if(InterestPawn.Health > 0
			&& InterestPawn == Other)
		{
			PrepToMug();
			StateChange = 1;
		}

		if(StateChange != 1)
			DangerPawnBump(Other, StateChange);
	}
	///////////////////////////////////////////////////////////////////////////////
	// You've watched them enough for prelim stuff, decide to really stalk them or not
	///////////////////////////////////////////////////////////////////////////////
	function DecideToPickThem()
	{
		local bool bPicked;

		if(InterestPawn.bPlayer)
		{
			if(FRand() < PICK_PLAYER_FOR_MUGGING)
			{
				PickThem();
				bPicked=true;
			}
		}
		else
		{
			if(FRand() < PICK_NPC_FOR_MUGGING)
			{
				PickThem();
				bPicked=true;
			}
		}
		// We didn't pick them, look again
		if(!bPicked)
			WatchSomeoneElse();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Start stalking this guy
	///////////////////////////////////////////////////////////////////////////////
	function PickThem()
	{
		statecount = 2 + Rand(STARE_COUNT);
		CurrentFloat = START_APPROACH_RADIUS;
		TimeWatchingPrey = 0.0;
		GotoStateSave('WatchPrey');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		Focus = InterestPawn;
	}

Begin:
	Sleep(1.0);
KeepWatching:
	CheckPrey();
	// Stand around scope the area for someone to mug
	Sleep(PREY_CHECK_TIME);
	statecount--;
	if(statecount <= 0)
		DecideToPickThem();
	Goto('KeepWatching');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// We watch this person thinking about mugging them
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchPrey extends CheckOutPossiblePrey
{
	///////////////////////////////////////////////////////////////////////////////
	// Make sure you have a line of sight to them
	///////////////////////////////////////////////////////////////////////////////
	function CheckPrey()
	{
		local float usedist;

		// If the interest dies, or becomes involved in a fight, lose interest in them
		if(PreyIsInvalid())
		{
			GotoStateSave('Thinking');
		}
		else
		{
			// Consider mugging them now
			if(TimeWatchingPrey > WATCH_PREY_MIN
				&& Frand() > (TimeWatchingPrey/WATCH_PREY_MAX))
				PrepToMug();
			// If you can't seem then, run closer
			else if(!FastTrace(InterestPawn.Location, MyPawn.Location))
			{
				SetEndGoal(InterestPawn, CurrentFloat);
				CurrentFloat=0.95*CurrentFloat;	// Bring the radius in some, so you can get
												// closer if this doesn't work
				if(CurrentFloat < DEFAULT_END_RADIUS)
					CurrentFloat = DEFAULT_END_RADIUS;
				SetNextState('WatchPrey');
				ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
				GotoStateSave('RunToTarget');
			}
			// If they get too far away, walk or run to catch up to them
			else
			{
				// Check the distance to them
				usedist = VSize(InterestPawn.Location-MyPawn.Location);
				if(usedist > RUN_TO_PREY)
				{
					SetEndPoint(InterestPawn.Location, RUN_TO_PREY-MyPawn.CollisionRadius);
					SetNextState('WatchPrey');
					ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
					GotoStateSave('RunToTarget');
				}
				else if(usedist > WALK_TO_PREY)
				{
					SetEndPoint(InterestPawn.Location, WALK_TO_PREY-MyPawn.CollisionRadius);
					SetNextState('WatchPrey');
					GotoStateSave('WalkToPrey');
				}
			}
		}
	}

Begin:
	Sleep(1.0);
KeepWatching:
	CheckPrey();
	// Stand around scope the area for someone to mug
	Sleep(PREY_CHECK_TIME);
	TimeWatchingPrey+=PREY_CHECK_TIME;
	/*
	// Check to look around shiftily a lot
	if(Rand(LOOK_SHIFTILY_FREQ) == 0)
	{
		MyPawn.PlayTurnHeadRightAnim(3.0 + FRand(), 0.8);
		Sleep(1.0+FRand());
		MyPawn.PlayTurnHeadLeftAnim(3.0 + FRand(), 0.8);
		Sleep(1.0+FRand());
	}
	*/
	Goto('KeepWatching');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToPrey
// Stalk the person you're interested in.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToPrey extends WalkToTarget
{
	ignores RespondToTalker, PerformInterestAction, RatOutAttacker, CheckDeadBody, CheckDeadHead,
		WatchFunnyThing, CheckDesiredThing, CheckForIntruder, CanStartConversation, 
		FreeToSeekPlayer, CanBeMugged, ForceGetDown;
	///////////////////////////////////////////////////////////////////////////////
	// Check for bumping the guy you want to mug
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local byte StateChange;

		// If you bump you're prey, just mug them now
		if(InterestPawn.Health > 0
			&& InterestPawn == Other)
		{
			PrepToMug();
			StateChange = 1;
		}

		if(StateChange != 1)
			DangerPawnBump(Other, StateChange);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DoMugging
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoMugging
{
	ignores DoWaitOnOtherGuy, SetupSideStep, SetupBackStep, SetupMoveForRunner, TryToSendAway,
		TryToGreetPasserby, DonateSetup, PerformInterestAction, CheckDesiredThing,
		StartConversation, RespondToQuestionNegatively, CheckDeadBody, CheckDeadHead, InterestIsAnnoyingUs, GetHitByDeadThing,
		QPointSaysMoveUpInLine, SetToMugPlayer, CanBeMugged,
		ForceGetDown, AllowOldState;

	///////////////////////////////////////////////////////////////////////////////
	// Only hear our guy
	///////////////////////////////////////////////////////////////////////////////
	function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
									FPSPawn CreatorPawn, 
									Actor OriginActor,
									vector blipLoc,
									optional out byte StateChange)
	{
		if(CreatorPawn == Attacker
			|| CreatorPawn == InterestPawn)
			Super.GetReadyToReactToDanger(dangerhere, CreatorPawn, OriginActor, blipLoc, StateChange);
	}

	///////////////////////////////////////////////////////////////////////////////
	// See if we can see our guy
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		SetRotation(MyPawn.Rotation);

		if(LookAtMe == InterestPawn)
			ActOnPawnLooks(LookAtMe);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check the interest once more to see if it's okay to try to mug them
	///////////////////////////////////////////////////////////////////////////////
	function FinalValidCheck()
	{
		local float usedist;
		local byte StateChange;

		usedist = VSize(InterestPawn.Location - MyPawn.Location);
		// If something is in the way, and you're already close enough, give up
		if(!FastTrace(MyPawn.Location, InterestPawn.Location))
		{
			if(usedist < (MUG_MIN_RADIUS + MyPawn.CollisionRadius))
			{
				return;
			}
			// something's in the way, but we can get closer
			else
			{
				PrepToMug();
				return;
			}
		}
		
		// If we didn't run to get closer, see about mugging him
		if(PreyIsInvalid())
			GotoStateSave('Thinking');
		else 
		{
			//  If you're not close enough to reasonably mug them, run closer
			if(usedist > MUG_MAX_RADIUS)
				PrepToMug();
			else if(PersonController(InterestPawn.Controller) != None)
			{
				PersonController(InterestPawn.Controller).CanBeMugged(MyPawn, StateChange);
				// If they can't 'talk' right now, then stop stalking them
				if(StateChange == 0)
				{
					GotoStateSave('Thinking');
					return;
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function SetupGrabMoney()
	{
		local MoneyPickup mp;
		local vector checkv;

		checkv = (MyPawn.Location + InterestPawn.Location)/2;
		foreach CollidingActors(class'MoneyPickup', mp, MUG_MAX_RADIUS, checkv)
		{
			if(mp != None)
				Focus = mp;
		}

		if(MoneyPickup(Focus) != None)
		{
			// Scan the area for the new money
			bDontSetFocus=true;
			SetEndGoal(Focus, TIGHT_END_RADIUS);
			SetNextState(GetStateName(), 'PickingUpMoney');
			ScreamState=SCREAM_STATE_NONE; // clear scream state before we run to the money
			GotoStateSave('RunToTarget');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		if(InterestPawn != None)
			SetAttacker(InterestPawn);
	}
	function EndState()
	{
		InterestPawn = None;
		bImportantDialog=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DoNonPlayerMugging, mug AI characters
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoNonPlayerMugging extends DoMugging
{
	///////////////////////////////////////////////////////////////////////////////
	// Magically grant them cash to throw
	///////////////////////////////////////////////////////////////////////////////
	function GrantMugeeCash()
	{
		local Inventory thisinv;
		local P2PowerupInv pinv;
		local int GiveAmount;
		local byte CreatedNow;

		thisinv = InterestPawn.CreateInventoryByClass(class'Inventory.MoneyInv', CreatedNow);

		GiveAmount = Rand(CASH_GIVE_RAND) + CASH_GIVE_BASE;

		pinv = P2PowerupInv(thisinv);

		// Add in what we gave them
		if(pinv != None)
		{
			pinv.AddAmount(GiveAmount);
			// set it as your item
			if(InterestPawn != None)
				InterestPawn.SelectedItem = pinv;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make him say he's going to attack
	///////////////////////////////////////////////////////////////////////////////
	function SetupInterestAttackMe()
	{
		local PersonController perc;

		if(InterestPawn != None)
		{
			perc = PersonController(InterestPawn.Controller);
			if(perc != None
				&& perc.IsInState('GettingMugged'))
			{
				// Yell before you attack
				SayTime = P2Pawn(InterestPawn).Say(P2Pawn(InterestPawn).myDialog.lDecideToFight, bImportantDialog);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// This guy's not going to take it!
	///////////////////////////////////////////////////////////////////////////////
	function MakeInterestAttackMe()
	{
		local PersonController perc;

		if(InterestPawn != None)
		{
			perc = PersonController(InterestPawn.Controller);
			if(perc != None
				&& perc.IsInState('GettingMugged'))
			{
				perc.SetAttacker(MyPawn);
				perc.GotoStateSave('ShootAtAttacker');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// This guy's not going to take it! (even though they don't have a weapon)
	///////////////////////////////////////////////////////////////////////////////
	function MakeInterestKickMe()
	{
		local PersonController perc;

		if(InterestPawn != None)
		{
			perc = PersonController(InterestPawn.Controller);
			if(perc != None
				&& perc.IsInState('GettingMugged'))
			{
				bDontSetFocus=false;
				perc.SetAttacker(MyPawn);
				perc.SetEndGoal(MyPawn, DEFAULT_END_RADIUS);
				perc.SetNextState('GettingMugged', 'DoKicking');
				perc.ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
				perc.GotoStateSave('RunToTarget');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// He's going to go find a cop
	///////////////////////////////////////////////////////////////////////////////
	function MakeInterestRunAway()
	{
		local PersonController perc;

		if(InterestPawn != None)
		{
			perc = PersonController(InterestPawn.Controller);
			if(perc != None
				&& perc.IsInState('GettingMugged'))
			{
				perc.bDontSetFocus=false;
				perc.GotoStateSave('LookForCop');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Unhook NPC
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(InterestPawn != None
			&& PersonController(InterestPawn.Controller) != None
			&& PersonController(InterestPawn.Controller).IsInState('GettingMugged'))
		{
			PersonController(InterestPawn.Controller).GotoStateSave('LookForCop');
		}
		Super.EndState();
	}

Begin:
	FinalValidCheck();
	PersonController(InterestPawn.Controller).SetupGettingMugged(MyPawn);
	MyPawn.SetMood(MOOD_Combat, 1.0);
	SwitchToBestWeapon();
	Sleep(0.5);

	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

	// First yells to give them all their money
	PrintDialogue("Give me all your money!");
	SayTime = Say(MyPawn.myDialog.lDoMugging, bImportantDialog);
	MakeMarker(class'BadGuyYellMarker', MyPawn, MyPawn);
	Sleep(SayTime+FRand());

	// If you have a weapon, fight this punk
	if(P2Pawn(InterestPawn).bHasViolentWeapon)
	{
		PrintDialogue("You're not going to take my money!");
		SayTime = P2Pawn(InterestPawn).Say(P2Pawn(InterestPawn).myDialog.ldecidetofight, bImportantDialog);
		SetupInterestAttackMe();
		Sleep(SayTime);
		MakeInterestAttackMe();
		// Wait to get beaten up
		Sleep(3.0);
	}
	else	// These are unarmed bystanders
	{
		// Some people are strong enough to not put with this crap and
		// will kick him instead of giving him money
		if(FRand() < MyPawn.Cajones 
			|| Rand(MUG_FREQ) == 0)
		{
			PrintDialogue("You're not going to take my money!");
			SayTime = P2Pawn(InterestPawn).Say(P2Pawn(InterestPawn).myDialog.ldecidetofight, bImportantDialog);
			Sleep(SayTime);
			MakeInterestKickMe();
			// Wait to get beaten up
			Sleep(3.0);
		}
		else	// Others will get scared and just end up
			// giving him their money
		{
			// Second yells about doing that
			PrintDialogue("help, he's mugging me!!");
			SayTime = P2Pawn(InterestPawn).Say(P2Pawn(InterestPawn).myDialog.lGettingMugged, bImportantDialog);
			Sleep(SayTime+FRand());

			// Give the interest money to throw
			P2MocapPawn(InterestPawn).PlayTalkingGesture(2.0);
			Sleep(0.5);	// Pause as throwing
			GrantMugeeCash();
			P2Pawn(InterestPawn).TossThisInventory(GenTossVel(InterestPawn), InterestPawn.SelectedItem);

			// Cry some more then run
			PrintDialogue("I'm crying, he's mugging me!!");
			SayTime = P2Pawn(InterestPawn).Say(P2Pawn(InterestPawn).myDialog.lCrying, bImportantDialog);
			Sleep(SayTime+FRand());

			// Now he runs away screaming
			MakeInterestRunAway();

			// Now I run away to count my money, hahahaaa!
			SwitchToHands();
			Sleep(0.3);

			SetupGrabMoney();
			// If we don't go after the money, then run
			GotoStateSave(GetStateName(), 'RunningAway');
		}
	}

RunningAway:
	Sleep(0.1);
	if(!PickRandomDest())
		Goto('RunningAway');	// Didn't find a valid point, try again
	SetNextState('Thinking');
	ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
	GotoStateSave('RunToTarget');

PickingUpMoney:
	MyPawn.ShouldCrouch(true);
	Sleep(0.3);
	GrabbingMoney();
	MyPawn.ShouldCrouch(false);
	Sleep(0.3);
	Goto('RunningAway');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DoPlayerMugging
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoPlayerMugging extends DoMugging
{
	///////////////////////////////////////////////////////////////////////////////
	// Check the interest once more to see if it's okay to try to mug them
	///////////////////////////////////////////////////////////////////////////////
	function FinalValidCheck()
	{
		// If the player is engaged with a cashier, don't mess with him
		if(InterestPawn != None
			&& P2Player(InterestPawn.Controller).CanBeMugged(MyPawn))
			Super.FinalValidCheck();
		else
			GotoStateSave('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to make sure the player is still close if he's dropped the money or not
	///////////////////////////////////////////////////////////////////////////////
	function CheckPlayerAndMoney()
	{
		// If the player gets too far away, attack him
		if(VSize(InterestPawn.Location - MyPawn.Location) > MUG_MAX_RADIUS)
			AttackPlayerNow();
		else	// Look around for the money dropped and go there if there's any
			SetupGrabMoney();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function AttackPlayerNow()
	{
		SetAttacker(InterestPawn);
		GotoStateSave('ShootAtAttacker', 'FireNowPrep');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find the money for the player
	///////////////////////////////////////////////////////////////////////////////
	function SwitchToPlayerMoney()
	{
		if(InterestPawn != None
			&& P2Player(InterestPawn.Controller) != None)
			P2Player(InterestPawn.Controller).SwitchToThisPowerup(InterestInventoryClass.default.InventoryGroup,
							InterestInventoryClass.default.GroupOffset);
	}

	///////////////////////////////////////////////////////////////////////////////
	// You're getting the money
	///////////////////////////////////////////////////////////////////////////////
	function bool GrabbingMoney()
	{
		if(!Global.GrabbingMoney())
		{
			// If you didn't get the money (someone else must have grabbed it)
			// take it out on the dude here, because he more than likely took it.
			AttackPlayerNow();
			return false;
		}
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		// Try to unhook the player from this state
		if(Attacker != None
			&& P2Player(Attacker.Controller) != None)
			P2Player(Attacker.Controller).UnhookPlayerGetMugged();
		else if(InterestPawn != None
			&& P2Player(InterestPawn.Controller) != None)
			P2Player(InterestPawn.Controller).UnhookPlayerGetMugged();
		Super.EndState();
	}

Begin:
	FinalValidCheck();
	P2Player(InterestPawn.Controller).SetupGettingMugged(MyPawn);
	bImportantDialog=true;
	MyPawn.SetMood(MOOD_Combat, 1.0);
	SwitchToBestWeapon();
	Sleep(0.5);

	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

	// First yells to give them all their money
	SwitchToPlayerMoney();
	PrintDialogue("Give me all your money!");
	SayTime = Say(MyPawn.myDialog.lDoMugging, bImportantDialog);
	MakeMarker(class'BadGuyYellMarker', MyPawn, MyPawn);
	Sleep(SayTime+FRand());

	// Second yells about doing that
	PrintDialogue("Dude, help, he's mugging me!!");
	SayTime = P2Pawn(InterestPawn).Say(P2Pawn(InterestPawn).myDialog.lNegativeResponse, bImportantDialog);
	Sleep(SayTime+FRand());

	// How many iterations we'll go through before we get mad that the player
	// hasn't dropped the money yet.
	statecount = Rand(PLAYER_WAIT_RAND) + PLAYER_WAIT_BASE;

	// Wait for the player to drop the money
WaitingForMoney:
	Sleep(MONEY_WAIT_UPDATE);
	CheckPlayerAndMoney();
	MakeMarker(class'BadGuyYellMarker', MyPawn, MyPawn);
	statecount--;
	// This is your last warning--better do it!
	if(statecount == PLAYER_WAIT_MIN)
	{
		PrintDialogue("I said, give me all your money!");
		SayTime = Say(MyPawn.myDialog.lDoMugging, bImportantDialog);
		MakeMarker(class'BadGuyYellMarker', MyPawn, MyPawn);
		P2Player(InterestPawn.Controller).EscalateMugging();
		Sleep(SayTime+FRand());
		Goto('WaitingForMoney');
	}
	else if(statecount <= 0)
		AttackPlayerNow();
	else
		Goto('WaitingForMoney');

RunningAway:
	Sleep(0.1);
	if(!PickRandomDest())
		Goto('RunningAway');	// Didn't find a valid point, try again
	SetNextState('Thinking');
	ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
	GotoStateSave('RunToTarget');

PickingUpMoney:
	// Now I run away to count my money, hahahaaa!
	SwitchToHands();
	Sleep(0.3);
	MyPawn.ShouldCrouch(true);
	Sleep(0.3);
	GrabbingMoney();
	MyPawn.ShouldCrouch(false);
	Sleep(0.3);
	// Make people laugh at the dude getting mugged
	MakeMarker(class'FunnyThingMarker', MyPawn, Attacker);
	Goto('RunningAway');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttacker
// Mugger is special.. if he gets to the point of calling CheckToMoveAround,
// then he's completed a full attack sequence, therefore--he's ready to cowardly
// run away! Lower PainThreshold to make him run away early after getting hurt.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttacker
{
	///////////////////////////////////////////////////////////////////////////
	// Don't do anything strategic here.. just run away
	///////////////////////////////////////////////////////////////////////////
	function CheckToMoveAround()
	{
		if(PickRandomDest())
		{
			SetNextState('Thinking');
			ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
			GotoStateSave('RunToTarget');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Don't do anything strategic here.. just run away
	///////////////////////////////////////////////////////////////////////////////
	function PerformStrategicMoves(optional bool bForce, optional bool bForceBackUp, optional out byte StateChange)
	{
		if(PickRandomDest())
		{
			SetNextState('Thinking');
			ScreamState=SCREAM_STATE_NONE; // clear scream state before we run
			GotoStateSave('RunToTarget');
		}
	}
}


defaultproperties
{
	SwitchWeaponFreq=0.0
}
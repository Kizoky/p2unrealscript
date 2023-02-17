///////////////////////////////////////////////////////////////////////////////
// YeelandController
// Copyright 2014, Running With Scissors, Inc.
//
// Controller for Yeeland
// We're not actually a cashier, but we act a lot like one, so it extends
// from cashier.
//
// If the Q line attached to this guy takes any regular pawns, it will act
// like a cashier for those pawns but not for the Dude
///////////////////////////////////////////////////////////////////////////////
class YeelandController extends FFCashierController;

var bool bSawDude;	// True if we talked to the dude already. Don't repeat the conversation.
var int DudeStateCount;

///////////////////////////////////////////////////////////////////////////////
// If your attacker bumps you, don't put up with it, spin around and notice him
///////////////////////////////////////////////////////////////////////////////
function DangerPawnBump( Actor Other, optional out byte StateChange )
{
	local P2Pawn ppawn;
	local PersonController pcont;
	
	// Clear log spam
	if (Attacker == None)
		Attacker = None;
	
	ppawn = P2Pawn(Other);
	if(ppawn != None)
		pcont = PersonController(ppawn.Controller);

	// Have Yeeland ignore this... dude might be trucking around some big weapons
	// and we don't want Yeeland to start attacking him just for doing his grunt work.
	
	/*
	// If the pawn bumps us and we don't have an enemy, maybe
	// make him the attacker
	if(Attacker == None
		&& ppawn != None)
	{
		if(ppawn.bPlayer)
		{
			// I hate him, so attack him
			if(MyPawn.bPlayerIsEnemy)
				SetAttacker(ppawn);
			// If the player has a violent weapon out, psychically know to
			// turn around and check.. sort of imagine the dude is bumping
			// them with the weapon he has out--like a pistol to the back.
			// Make sure you're not a friend of the player and make
			// sure he's not dressed as a cop--they get to do anything.
			else if(P2Weapon(ppawn.Weapon) != None
					&& P2Weapon(ppawn.Weapon).bBumpStartsFight
					&& !MyPawn.bPlayerIsFriend
					&& !DudeDressedAsCop(ppawn))
				SetAttacker(ppawn);
		}
		else
		{
			// If you're not in the same gang, and it's not a cop that bumped you
			// then attack them or run, for bumping you with a bad weapon
			// and not the dude as a cop
			if(!SameGang(ppawn)
				&& !ppawn.bAuthorityFigure
				&& !DudeDressedAsCop(ppawn)
				&& P2Weapon(ppawn.Weapon) != None
				&& P2Weapon(ppawn.Weapon).bBumpStartsFight)
				SetAttacker(ppawn);
		}
	}
	*/

	// If our attacker bumps us (could be the new player enemy)
	if(Attacker != None
			&& (FPSPawn(Other) == Attacker
				|| FriendIsEnemyTarget(P2Pawn(Other))))
	{
		DangerPos = Other.Location;
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		InterestPawn = Attacker;
		if(MyPawn.bHasViolentWeapon)
			SetNextState('AssessAttacker');
		else
		{
			if(PickScreamingStill())
				SetNextState('ScreamingStill');
			else
				SetNextState('FleeFromAttacker');
		}
		GotoStateSave('ConfusedByDanger');
		StateChange=1;
	}

	// If a crazy running guy bumps us, check what the disturbance was
	// If our attacker bumps us (could be the new player enemy)
	if(Attacker == None
		&& pcont != None
		&& pcont.Attacker != None)
	{
		DangerPos = Other.Location;
		if(FRand() < 0.5)
		{
			SetupBackStep(SIDE_STEP_DIST, SIDE_STEP_DIST);
		}
		else
		{
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			InterestPawn = ppawn;
			SetNextState('WatchThreateningPawn');
			GotoStateSave('ConfusedByDanger');
		}
		StateChange=1;
	}

	// If you don't care about him, he's not secretly got a gun out
	// Then just check to see if he's bumping into you too hard. If he's
	// running into you, then get mad
	if(ppawn != None)
	{
		// If they are very close to running...
		if(VSize(ppawn.Velocity) > (0.9*ppawn.GroundSpeed))
			InterestIsAnnoyingUs(ppawn, true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Same as super, but don't switch to the dude's money.
// We're not selling him anything.
///////////////////////////////////////////////////////////////////////////////
function SetupDudeCustomer()
{
	local P2Player aplayer;

	aplayer = P2Player(InterestPawn.Controller);

	if(aplayer != None)
	{
		CustomerPawn = P2MoCapPawn(InterestPawn);

		// link to the cashier who called you over
		aplayer.InterestPawn = MyPawn;
		aplayer.bDealingWithCashier=true;

		// Have them switch to the motherboards, since this is the item that they
		// want to hand over. They won't actually be handing them over just yet though >:D
		aplayer.SwitchToThisPowerup(default.InterestInventoryClass.default.InventoryGroup,
										default.InterestInventoryClass.default.GroupOffset);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ExchangeWithDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ExchangeWithDude
{
WatchForCustomerReturn:
	// assigns statecount, we can't change states in a function that returns a variable
	CheckForCustomerProx();
	if(statecount == 2)
		Goto('Begin'); // he's ready to buy things again
	else if(statecount == 1)
	{
		Cleanup();
		GotoStateSave('WaitForCustomers');// he's too far away, so just wait on other customers
	}
	Sleep(1.0);
	Goto('WatchForCustomerReturn');

Begin:
	SetupCustomer();

	// With these cashiers, you don't have to bring the product to them, you go to them
	// and ask for it. They give the product and you give them the money.
	bResetInterests=false;
	// Just talk to the dude, like normal
	if (bSawDude)
		GotoState('RepeatDudeVisit');
	else
		GotoState('TakePaymentFromDude');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RepeatDudeVisit
// Dude came back, maybe remind him where he should go? It's not that hard.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RepeatDudeVisit extends TalkingToDudeMaster
{
Begin:
	// Guy suggests the kennels
	PrintDialogue("Follow me and we'll work out a deal");
	TalkSome(MyPawn.myDialog.lArcade_Yeeland_MeetMeInBack,,true);
	Sleep(SayTime);
	
	// Trigger events again, in case they didn't trigger the first time
	if (MyCashReg != None)
	{
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudePays, MyPawn, InterestPawn);
	}

	// return to handling the cash register
	GotoState('WaitForCustomers');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TakePaymentFromDude
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakePaymentFromDude
{
	// Don't hand over any items, we're not an actual cashier
	function FinishTransaction();
	
Begin:

	if (DudeStateCount == 0)
	{
		// cashier says hi
		TalkSome(MyPawn.myDialog.lGreeting,,true);
		PrintDialogue("Greeting");
		Sleep(SayTime);
		DudeStateCount = 1;
	}

	if (DudeStateCount == 1)
	{
		// dude says hi
		PrintDialogue(InterestPawn$" greeting ");
		TalkSome(CustomerPawn.myDialog.lGreeting, CustomerPawn,true);
		Sleep(SayTime);
		DudeStateCount = 2;
	}

	if (DudeStateCount == 2)
	{
		// Dude asks about motherboards
		PrintDialogue(InterestPawn$" <Dude> I'm here to deliver these motherboards");
		TalkSome(CustomerPawn.myDialog.lArcade_Dude_DeliverGame, CustomerPawn, true);
		Sleep(SayTime+FRand());
		DudeStateCount = 3;
	}

	if (DudeStateCount == 3)
	{
		// Yeeland rejects
		PrintDialogue("I must reject your game based on my moral grounds");
		SayTime = MyPawn.Say(MyPawn.myDialog.lArcade_Yeeland_MoralGrounds);
		MyPawn.PlayAnim('s_idle_stretch', 1.0, 0.15);
		Sleep(SayTime+FRand());
		DudeStateCount = 4;
	}

	if (DudeStateCount == 4)
	{
		// Corey counteroffer
		PrintDialogue(InterestPawn$" <Corey> I'll scramble your brains over those moral grounds");
		TalkSome(CustomerPawn.myDialog.lArcade_CoreyDude_MoralGrounds,CustomerPawn,true);
		Sleep(SayTime+FRand());
		DudeStateCount = 5;
	}
	
	if (DudeStateCount == 5)
	{
		// Yeeland offers deal
		PrintDialogue("Follow me and we'll work out a deal");
		TalkSome(MyPawn.myDialog.lArcade_Yeeland_MeetMeInBack,,true);
		Sleep(SayTime);
		
		bSawDude = true;

		// Trigger events. In-level scripted actions will handle the second part of this setup.
		if (MyCashReg != None)
		{
			TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
			TriggerEvent(MyCashReg.TriggerAfterDudePays, MyPawn, InterestPawn);
		}

		// return to handling the cash register, if for some reason the event didn't go off
		GotoState('WaitForCustomers');
		DudeStateCount = 6;
	}
}

defaultproperties
{
	InterestInventoryClass=class'PLInventory.MotherboardInv'
	bSwitchToMoney=false
}